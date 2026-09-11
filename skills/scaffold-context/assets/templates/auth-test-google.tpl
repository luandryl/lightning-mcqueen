"""Exercise OIDC with signed local tokens; no Google account or network required."""
import time
from datetime import UTC, datetime, timedelta
from urllib.parse import parse_qs, urlsplit

import httpx
import pytest
from joserfc import jwt
from joserfc.jwk import RSAKey

from app.api import auth
from app.core.config import Settings
from app.db.mongo import get_database

KEY = RSAKey.generate_key(2048, parameters={"kid": "local-test"})
PUBLIC_KEY = KEY.as_dict(private=False)
ORIGIN = "http://localhost:{{ frontend_port }}"
COOKIE = "{{ project_name }}_session"


async def start_login(api, mock, overrides=None, signing_key=None):
    mock.get("https://accounts.google.com/.well-known/openid-configuration").respond(200, json={
        "issuer": "https://accounts.google.com",
        "authorization_endpoint": "https://accounts.google.com/o/oauth2/v2/auth",
        "token_endpoint": "https://oauth2.googleapis.com/token",
        "jwks_uri": "https://www.googleapis.com/oauth2/v3/certs",
        "id_token_signing_alg_values_supported": ["RS256"],
    })
    mock.get("https://www.googleapis.com/oauth2/v3/certs").respond(200, json={"keys": [PUBLIC_KEY]})
    response = await api.get("/v1/auth/google/login")
    assert response.status_code == 302
    params = parse_qs(urlsplit(response.headers["location"]).query)
    assert params["code_challenge_method"] == ["S256"]
    assert params["redirect_uri"] == [ORIGIN + "/v1/auth/google/callback"]
    claims = {"iss": "https://accounts.google.com", "aud": "test-client", "sub": "google-user-123",
              "email": "ana@example.test", "email_verified": True, "name": "Ana",
              "iat": int(time.time()), "exp": int(time.time()) + 300, "nonce": params["nonce"][0]}
    claims.update(overrides or {})
    encoded = jwt.encode({"alg": "RS256", "kid": "local-test"}, claims, signing_key or KEY)
    exchange = mock.post("https://oauth2.googleapis.com/token").mock(return_value=httpx.Response(
        200, json={"access_token": "not-a-real-token", "token_type": "Bearer", "id_token": encoded},
    ))
    return params["state"][0], exchange


async def finish_login(api, state):
    return await api.get("/v1/auth/google/callback", params={"state": state, "code": "local-code"})


async def test_guest_cannot_read_private_session(api):
    assert (await api.get("/v1/auth/session")).status_code == 401


async def test_valid_login_and_revocable_logout(api, respx_mock):
    state, exchange = await start_login(api, respx_mock)
    response = await finish_login(api, state)
    assert response.status_code == 303
    assert response.headers["location"] == ORIGIN + "/"
    assert exchange.called
    assert b"code_verifier=" in exchange.calls[0].request.content
    assert "httponly" in response.headers["set-cookie"].lower()
    assert "samesite=lax" in response.headers["set-cookie"].lower()
    cookie = api.cookies.get(COOKIE)
    assert "not-a-real-token" not in cookie
    session = await api.get("/v1/auth/session")
    assert session.json() == {"sub": "google-user-123", "email": "ana@example.test", "name": "Ana"}
    assert session.headers["cache-control"] == "no-store"
    assert (await api.post("/v1/auth/logout", headers={"Origin": "https://evil.example"})).status_code == 403
    assert (await api.post("/v1/auth/logout")).status_code == 403
    assert (await api.get("/v1/auth/session")).status_code == 200
    assert (await api.post("/v1/auth/logout", headers={"Origin": ORIGIN})).status_code == 204
    assert (await api.get("/v1/auth/session")).status_code == 401
    api.cookies.clear()
    api.cookies.set(COOKIE, cookie)
    assert (await api.get("/v1/auth/session")).status_code == 401


async def test_state_mismatch_rejects_before_token_exchange(api, respx_mock):
    await start_login(api, respx_mock)
    response = await finish_login(api, "forged-state")
    assert response.headers["location"].endswith("auth_error=failed")
    assert (await api.get("/v1/auth/session")).status_code == 401


@pytest.mark.parametrize("claims", [
    {"nonce": "wrong"}, {"aud": "another-client"}, {"iss": "https://evil.example"},
    {"exp": 1}, {"email_verified": False}, {"sub": ""},
])
async def test_invalid_identity_rejected(api, respx_mock, claims):
    state, _ = await start_login(api, respx_mock, claims)
    response = await finish_login(api, state)
    assert response.headers["location"].endswith("auth_error=failed")
    assert (await api.get("/v1/auth/session")).status_code == 401
    assert await get_database().auth_sessions.count_documents({}) == 0


async def test_invalid_signature_rejected(api, respx_mock):
    other_key = RSAKey.generate_key(2048)
    state, _ = await start_login(api, respx_mock, signing_key=other_key)
    response = await finish_login(api, state)
    assert response.headers["location"].endswith("auth_error=failed")
    assert (await api.get("/v1/auth/session")).status_code == 401


async def test_expired_and_tampered_sessions_rejected(api, respx_mock):
    state, _ = await start_login(api, respx_mock)
    await finish_login(api, state)
    cookie = api.cookies.get(COOKIE)
    api.cookies.clear()
    api.cookies.set(COOKIE, "tampered." + cookie)
    assert (await api.get("/v1/auth/session")).status_code == 401
    api.cookies.clear()
    api.cookies.set(COOKIE, cookie)
    await get_database().auth_sessions.update_many({}, {"$set": {"expires_at": datetime.now(UTC) - timedelta(seconds=1)}})
    assert (await api.get("/v1/auth/session")).status_code == 401


async def test_provider_denial_does_not_authenticate(api):
    response = await api.get("/v1/auth/google/callback", params={"error": "access_denied"})
    assert response.headers["location"].endswith("auth_error=failed")
    assert (await api.get("/v1/auth/session")).status_code == 401


async def test_unconfigured_login_is_unavailable(api, monkeypatch):
    monkeypatch.setattr(auth.settings, "google_client_id", "")
    assert (await api.get("/v1/auth/google/login")).status_code == 503
    assert (await api.get("/v1/auth/session")).status_code == 401


def test_production_requires_https_and_strong_session_secret():
    with pytest.raises(ValueError):
        Settings(app_env="prod", public_origin=ORIGIN)
    with pytest.raises(ValueError):
        Settings(session_secret="short")
    assert Settings(app_env="prod", public_origin="https://example.test").public_origin == "https://example.test"
