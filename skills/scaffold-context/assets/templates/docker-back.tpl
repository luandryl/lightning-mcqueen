ARG SERVICE=back

# ---------- back: FastAPI + Motor + SQLAlchemy/pymssql ----------
FROM python:3.11-slim AS back
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
COPY {{ backend_dir }}requirements.txt ./requirements.txt
RUN pip install -r requirements.txt
COPY {{ backend_dir }}pyproject.toml ./
COPY {{ backend_dir }}app ./app
COPY build/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
# Processo não roda como root. UID fixo facilita runAsUser/fsGroup no chart.
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin app \
    && chown -R app:app /app
USER app
ENV SERVICE=back
EXPOSE {{ backend_port }}
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

FROM ${SERVICE}
