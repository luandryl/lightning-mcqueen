"""Versão do back (o front exibe no rodapé)."""

from __future__ import annotations

from fastapi import APIRouter

from app import __version__

router = APIRouter(tags=["versao"])


@router.get("/version", summary="Versão da API")
async def versao() -> dict[str, str]:
    return {"service": "{{ project_name }}-back", "version": __version__}
