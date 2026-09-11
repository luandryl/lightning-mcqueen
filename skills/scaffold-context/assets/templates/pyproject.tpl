[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "{{ project_name }}-back"
version = "0.1.0"
description = {{ description_json }}
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.30.0",
    "motor>=3.5.1",
    "pydantic>=2.7.0",
    "pydantic-settings>=2.3.0",
    "structlog>=24.1.0",
    "httpx>=0.27.0",
    "python-ulid>=3.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.2.0",
    "pytest-asyncio>=0.23.0",
    "mongomock-motor>=0.0.34",
    "respx>=0.21.1",
    "httpx>=0.27.0",
    "ruff>=0.5.0",
    "mypy>=1.10.0",
]

[tool.setuptools.packages.find]
include = ["app*"]
exclude = ["tests*"]

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "W", "I", "UP", "B", "C4", "SIM"]
ignore = ["E501"]

[tool.ruff.format]
quote-style = "double"

[tool.mypy]
python_version = "3.11"
strict = false
ignore_missing_imports = true
plugins = ["pydantic.mypy"]

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
python_files = ["test_*.py"]
filterwarnings = [
    "ignore::DeprecationWarning",
]
