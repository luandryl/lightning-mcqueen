"""Cobertura dos health checks."""

from __future__ import annotations

from app import __version__


async def test_health_e_liveness_sem_dependencias(api):
    resp = await api.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok", "service": "{{ project_name }}-back", "version": __version__}
    assert resp.headers["X-Request-Id"]


async def test_ready_ok_com_mongo(api):
    resp = await api.get("/health/ready")
    assert resp.status_code == 200
    assert resp.text == "ok"


async def test_ready_degradado_sem_mongo(api_sem_mongo):
    resp = await api_sem_mongo.get("/health/ready")
    assert resp.status_code == 503
    assert resp.text.startswith("degraded: mongo")


async def test_version(api):
    resp = await api.get("/v1/version")
    assert resp.status_code == 200
    assert resp.json()["version"] == __version__
