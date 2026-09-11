name: Back CI

on:
  push:
    branches:
      - main
      - develop
      - "feature-*"
      - "feature/**"
    paths:
      - "{{ backend_glob }}"
      - ".github/workflows/back-ci.yml"
  pull_request:
    paths:
      - "{{ backend_glob }}"

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: {{ backend_workdir }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: pip
      - name: Install
        run: pip install -e ".[dev]"
      - name: Lint
        run: ruff check app tests
      - name: Typecheck
        run: mypy app
      - name: Test
        run: pytest -q
