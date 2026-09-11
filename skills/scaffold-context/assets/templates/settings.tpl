from functools import lru_cache
from typing import Literal

from pydantic import AliasChoices, Field
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
