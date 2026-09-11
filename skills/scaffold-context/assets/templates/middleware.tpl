"""Middlewares HTTP da aplicação."""

from __future__ import annotations

import time
from uuid import uuid4

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

from app.core.logging import get_logger, set_request_id

logger = get_logger("http")

REQUEST_ID_HEADER = "X-Request-Id"


class RequestIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):  # type: ignore[override]
        request_id = request.headers.get(REQUEST_ID_HEADER) or f"req_{uuid4().hex}"
        set_request_id(request_id)
        request.state.request_id = request_id
        request.state.trace_id = request_id

        start = time.perf_counter()
        try:
            response: Response = await call_next(request)
        except Exception:
            elapsed_ms = round((time.perf_counter() - start) * 1000, 2)
            logger.exception(
                "request_failed",
                method=request.method,
                path=request.url.path,
                elapsedMs=elapsed_ms,
            )
            raise

        elapsed_ms = round((time.perf_counter() - start) * 1000, 2)
        response.headers[REQUEST_ID_HEADER] = request_id
        logger.info(
            "request_completed",
            method=request.method,
            path=request.url.path,
            status=response.status_code,
            elapsedMs=elapsed_ms,
        )
        return response
