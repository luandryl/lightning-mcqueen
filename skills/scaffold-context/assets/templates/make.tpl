.PHONY: install dev test fmt lint

PORT ?= {{ backend_port }}

install:
	pip install -e ".[dev]"

dev:
	uvicorn app.main:app --reload --host 0.0.0.0 --port $(PORT)

test:
	pytest -v

fmt:
	ruff format app tests
	ruff check --fix app tests

lint:
	ruff check app tests
	mypy app

