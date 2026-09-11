"""Google OIDC and revocable application sessions; no Google tokens in the browser."""
from datetime import UTC, datetime, timedelta
from hashlib import sha256
from secrets import token_urlsafe
from typing import Annotated

from authlib.integrations.base_client.errors import OAuthError
from authlib.integrations.starlette_client import OAuth
from fastapi import APIRouter, Depends, HTTPException, Request, Response
from fastapi.responses import RedirectResponse
from httpx import HTTPError
from joserfc.errors import JoseError
from pydantic import BaseModel

from app.core.config import get_settings
from app.db.mongo import get_database

router = APIRouter()
settings = get_settings()
oauth = OAuth()
oauth.register(
    name="google",
    client_id=settings.google_client_id,
    client_secret=settings.google_client_secret.get_secret_value(),
    server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
    client_kwargs={"scope": "openid email profile", "code_challenge_method": "S256"},
)


class User(BaseModel):
    sub: str
    email: str
    name: str


def session_key(sid: str) -> str:
    return sha256(sid.encode()).hexdigest()


async def require_user(request: Request) -> User:
    """Attach with Depends to every future private product route."""
    sid = request.session.get("sid")
    if not isinstance(sid, str):
        raise HTTPException(status_code=401, detail="Entre com sua conta Google.")
    record = await get_database().auth_sessions.find_one({
        "_id": session_key(sid), "expires_at": {"$gt": datetime.now(UTC)},
    })
    if not record:
        request.session.clear()
        raise HTTPException(status_code=401, detail="Sua sessão expirou. Entre novamente.")
    return User.model_validate(record["user"])


@router.get("/google/login")
async def login(request: Request):
    if not settings.google_client_id or not settings.google_client_secret.get_secret_value():
        raise HTTPException(status_code=503, detail="Login indisponível. Tente mais tarde.")
    try:
        return await oauth.google.authorize_redirect(
            request, settings.public_origin + "/v1/auth/google/callback",
        )
    except (OAuthError, HTTPError):
        return RedirectResponse(settings.public_origin + "/?auth_error=unavailable", status_code=303)


@router.get("/google/callback")
async def callback(request: Request):
    try:
        # Authlib validates state, nonce, signature, issuer, audience, and token expiry.
        token = await oauth.google.authorize_access_token(request)
        claims = token.get("userinfo", {})
        if (not isinstance(claims.get("sub"), str) or not claims["sub"]
                or claims.get("email_verified") is not True
                or not isinstance(claims.get("email"), str)):
            raise ValueError("Invalid identity")
        user = User(sub=claims["sub"], email=claims["email"],
                    name=claims.get("name") or claims["email"])
    except (OAuthError, JoseError, HTTPError, ValueError, KeyError):
        # Keep any existing session; failed login must not grant a new one.
        return RedirectResponse(settings.public_origin + "/?auth_error=failed", status_code=303)
    db = get_database()
    old_sid = request.session.get("sid")
    if isinstance(old_sid, str):
        await db.auth_sessions.delete_one({"_id": session_key(old_sid)})
    sid = token_urlsafe(32)
    await db.auth_sessions.insert_one({
        "_id": session_key(sid), "user": user.model_dump(),
        "expires_at": datetime.now(UTC) + timedelta(hours=1),
    })
    request.session.clear()
    request.session["sid"] = sid
    return RedirectResponse(settings.public_origin + "/", status_code=303)


@router.get("/session", response_model=User)
async def session(response: Response, user: Annotated[User, Depends(require_user)]):
    response.headers["Cache-Control"] = "no-store"
    return user


@router.post("/logout", status_code=204)
async def logout(request: Request):
    # SameSite alone is insufficient for same-site cross-origin requests.
    if request.headers.get("origin") != settings.public_origin:
        raise HTTPException(status_code=403, detail="Origem inválida.")
    sid = request.session.get("sid")
    if isinstance(sid, str):
        await get_database().auth_sessions.delete_one({"_id": session_key(sid)})
    request.session.clear()
    return Response(status_code=204, headers={"Cache-Control": "no-store"})
