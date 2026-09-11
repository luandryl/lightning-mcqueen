"""Conexão e ciclo de vida do cliente MongoDB (Motor)."""

from __future__ import annotations

from typing import Any

from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase

from app.core.config import Settings, get_settings
from app.core.logging import get_logger

logger = get_logger("db.mongo")


class MongoState:
    """Estado global da conexão. Substituível em testes (override por mongomock)."""

    client: AsyncIOMotorClient | None = None
    database: AsyncIOMotorDatabase | None = None


_state = MongoState()


async def connect(settings: Settings | None = None) -> AsyncIOMotorDatabase:
    settings = settings or get_settings()
    if _state.client is None:
        _state.client = AsyncIOMotorClient(
            settings.mongo_connection_string,
            tz_aware=True,
            uuidRepresentation="standard",
        )
        _state.database = _state.client[settings.mongo_db]
        logger.info(
            "mongo_connected",
            uri=_safe_uri(settings.mongo_connection_string),
            db=settings.mongo_db,
        )
    assert _state.database is not None
    return _state.database


async def disconnect() -> None:
    if _state.client is not None:
        _state.client.close()
        logger.info("mongo_disconnected")
    _state.client = None
    _state.database = None


def get_database() -> AsyncIOMotorDatabase:
    if _state.database is None:
        raise RuntimeError("MongoDB ainda não foi inicializado. Rode connect() no startup.")
    return _state.database


def set_database_for_tests(db: Any) -> None:
    """Permite substituir o database por uma instância de mongomock-motor nos testes."""
    _state.database = db


def _safe_uri(uri: str) -> str:
    """Mascara usuário/senha da URI para log. ``rsplit`` cobre senha contendo ``@``."""
    if "://" in uri and "@" in uri:
        scheme, rest = uri.split("://", 1)
        _, host = rest.rsplit("@", 1)
        return f"{scheme}://***@{host}"
    return uri
