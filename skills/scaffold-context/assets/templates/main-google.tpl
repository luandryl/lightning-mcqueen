"""Entry point da aplicação FastAPI do {{ project_name }}."""

from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
from starlette.middleware.sessions import SessionMiddleware

from app import __version__
from app.api import auth as auth_router
from app.api import health as health_router
from app.api.v1 import versao as versao_router
from app.core.config import get_settings
from app.core.logging import configure_logging, get_logger
from app.core.middleware import RequestIdMiddleware
from app.db.mongo import connect, disconnect


@asynccontextmanager
async def lifespan(_: FastAPI):
    settings = get_settings()
    configure_logging(settings.log_level)
    logger = get_logger("startup")
    logger.info(
        "starting",
        version=__version__,
        env=settings.app_env,
    )

    # Client do Motor é lazy: connect() não abre socket. O ping deixa o log de boot
    # verdadeiro sem derrubar a app — quem segura tráfego é o readiness.
    db = await connect(settings)
    try:
        await db.command("ping")
        await db.auth_sessions.create_index("expires_at", expireAfterSeconds=0)
        logger.info("mongo_reachable", db=settings.mongo_db)
    except Exception as exc:  # noqa: BLE001
        logger.warning("mongo_unreachable", error=str(exc))
    try:
        yield
    finally:
        await disconnect()
        logger.info("stopped")


def create_app() -> FastAPI:
    settings = get_settings()
    configure_logging(settings.log_level)

    app = FastAPI(
        title="{{ project_name }} — API",
        description={{ description_json }},
        version=__version__,
        lifespan=lifespan,
        openapi_url="/v1/openapi.json",
        docs_url="/docs",
        redoc_url="/redoc",
    )

    app.add_middleware(RequestIdMiddleware)
    app.add_middleware(
        SessionMiddleware,
        secret_key=settings.session_secret.get_secret_value(),
        session_cookie="{{ project_name }}_session",
        max_age=3600,
        same_site="lax",
        https_only=settings.app_env not in {"dev", "test"},
    )
    app.include_router(auth_router.router, prefix="/v1/auth")
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list,
        allow_methods=["*"],
        allow_headers=["*"],
        allow_credentials=False,
        expose_headers=["X-Request-Id"],
    )

    # Health fora de /v1: probes do chart e diagnóstico não versionam.
    app.include_router(health_router.router)
    app.include_router(versao_router.router, prefix="/v1")

    @app.get("/", include_in_schema=False)
    async def root() -> RedirectResponse:
        return RedirectResponse(url="/docs")

    return app


app = create_app()
