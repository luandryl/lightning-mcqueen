import os

import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from mongomock_motor import AsyncMongoMockClient

os.environ["MONGO_URI"] = "mongodb://localhost:27017"
os.environ["APP_ENV"] = "test"
os.environ["PUBLIC_ORIGIN"] = "http://localhost:{{ frontend_port }}"
os.environ["SESSION_SECRET"] = "test-only-session-key-not-for-real-use-123456"
os.environ["GOOGLE_CLIENT_ID"] = "test-client"
os.environ["GOOGLE_CLIENT_SECRET"] = "test-only-client-secret"
from app.db.mongo import set_database_for_tests  # noqa: E402
from app.main import app  # noqa: E402


@pytest_asyncio.fixture
async def api():
    set_database_for_tests(AsyncMongoMockClient()["test"])
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield client
    set_database_for_tests(None)


@pytest_asyncio.fixture
async def api_sem_mongo():
    set_database_for_tests(None)
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield client
