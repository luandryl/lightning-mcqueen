"""Create local .env without overwriting existing settings or displaying secrets."""
from pathlib import Path
from secrets import token_urlsafe
import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument("--mode", choices=["native", "docker"], default="docker")
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
path = root / "{{ backend_dir }}.env"
body = (root / "{{ backend_dir }}.env.example").read_text()
body = body.replace("SESSION_SECRET=\n", "SESSION_SECRET=" + token_urlsafe(48) + "\n")
if args.mode == "docker":
    body = body.replace("PUBLIC_ORIGIN=http://localhost:{{ frontend_port }}", "PUBLIC_ORIGIN=http://localhost:{{ frontend_container_port }}")
fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
with os.fdopen(fd, "w") as handle:
    handle.write(body)
print("Local .env created. Set Google OAuth credentials privately in that file.")
