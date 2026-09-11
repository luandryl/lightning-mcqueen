from functools import lru_cache
from typing import Literal
from urllib.parse import urlsplit

from pydantic import AliasChoices, Field, SecretStr, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ---- App -------------------------------------------------------------------
    app_env: Literal["dev", "staging", "prod", "test"] = "dev"
    app_port: int = {{ backend_port }}
    log_level: str = "INFO"
    cors_origins: str = (
        "http://localhost:{{ frontend_port }},http://127.0.0.1:{{ frontend_port }},http://localhost:{{ frontend_container_port }},http://127.0.0.1:{{ frontend_container_port }}"
    )

    # Same-origin frontend proxy owns login, callback, and session requests.
    public_origin: str = "http://localhost:{{ frontend_port }}"
    google_client_id: str = ""
    google_client_secret: SecretStr = SecretStr("")
    session_secret: SecretStr = Field(min_length=32)

    @model_validator(mode="after")
    def validate_auth_config(self) -> "Settings":
        u = urlsplit(self.public_origin)
        if (u.scheme not in {"http", "https"} or not u.hostname or u.username
                or u.password or u.query or u.fragment or u.path):
            raise ValueError("PUBLIC_ORIGIN must be an origin without a path or credentials")
        if u.scheme != "https" and (self.app_env not in {"dev", "test"}
                                   or u.hostname not in {"localhost", "127.0.0.1", "[::1]", "::1"}):
            raise ValueError("PUBLIC_ORIGIN requires HTTPS except on local dev/test")
        return self

    # ---- Mongo -----------------------------------------------------------------
    mongo_db: str = "{{ project_name }}"

    # URI do Mongo/DocumentDB. Obrigatória. Em DocumentDB use retryWrites=false.
    mongo_connection_string: str = Field(
        validation_alias=AliasChoices("ConnectionString", "MONGO_URI"),
    )

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in (self.cors_origins or "").split(",") if o.strip()]


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
