"""Health checks: liveness sem dependências, readiness com ping no Mongo.

Ficam fora de ``/v1`` porque são consumidos pelas probes do chart e não versionam.
"""

from __future__ import annotations

from fastapi import APIRouter
from fastapi.responses import PlainTextResponse

from app import __version__
from app.db.mongo import get_database

router = APIRouter(tags=["health"])

SERVICE_NAME = "{{ project_name }}-back"


async def _mongo_status() -> tuple[bool, str]:
    try:
        db = get_database()
        await db.command("ping")
    except Exception as exc:  # noqa: BLE001
        return False, f"error: {exc}"
    return True, "ok"


@router.get("/health", summary="Liveness (não toca em dependências)")
async def health() -> dict[str, str]:
    return {"status": "ok", "service": SERVICE_NAME, "version": __version__}


@router.get("/health/ready", summary="Readiness (ping no Mongo)", response_class=PlainTextResponse)
async def health_ready() -> PlainTextResponse:
    ok, detail = await _mongo_status()
    if not ok:
        return PlainTextResponse(f"degraded: mongo {detail}", status_code=503)
    return PlainTextResponse("ok")


