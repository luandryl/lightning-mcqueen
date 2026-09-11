"""Logging estruturado em JSON (structlog) com correlação por request_id."""

from __future__ import annotations

import logging
import sys
from contextvars import ContextVar
from typing import Any

import structlog

_request_id_ctx: ContextVar[str | None] = ContextVar("request_id", default=None)


def set_request_id(request_id: str | None) -> None:
    """Define o identificador corrente de correlação (``requestId``/``traceId``)."""
    _request_id_ctx.set(request_id)


def get_request_id() -> str | None:
    return _request_id_ctx.get()


def _add_request_id(_: Any, __: str, event_dict: dict[str, Any]) -> dict[str, Any]:
    rid = _request_id_ctx.get()
    if rid:
        event_dict.setdefault("requestId", rid)
        event_dict.setdefault("traceId", rid)
    return event_dict


def configure_logging(level: str = "INFO") -> None:
    log_level = getattr(logging, level.upper(), logging.INFO)

    logging.basicConfig(format="%(message)s", stream=sys.stdout, level=log_level)

    structlog.configure(
        processors=[
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso", utc=True),
            _add_request_id,  # type: ignore[list-item]
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.JSONRenderer(),
        ],
        wrapper_class=structlog.make_filtering_bound_logger(log_level),
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(),
        cache_logger_on_first_use=True,
    )


def get_logger(name: str | None = None) -> structlog.stdlib.BoundLogger:
    return structlog.get_logger(name)
