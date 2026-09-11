"""Generator regression tests; stdlib only, no services or secrets."""
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
spec = importlib.util.spec_from_file_location("scaffold", ROOT / "scripts/scaffold.py")
scaffold = importlib.util.module_from_spec(spec)
spec.loader.exec_module(scaffold)


class CatalogTests(unittest.TestCase):
    def answers(self, **overrides):
        return dict(project_name="example", intent="An example scaffold", profile="fullstack",
                    profile_accepted=True, authentication="none", messaging="none", worker=False,
                    required_adapters=[], deployment="local", local_prerequisites_resolved=True,
                    docker=False) | overrides

    def test_original_profiles_without_auth(self):
        for profile in ["api-root", "api-monorepo", "fullstack"]:
            with self.subTest(profile=profile):
                a, _ = scaffold.validate(self.answers(profile=profile))
                output, _ = scaffold.expand(a)
                self.assertIn("@AGENTS.md", output["CLAUDE.md"]["body"])
                self.assertIn("AGENTS.md", output)
                prefix = "" if profile == "api-root" else "back/"
                self.assertIn(prefix + "app/main.py", output)
                self.assertNotIn(prefix + "app/api/auth.py", output)
                self.assertNotIn("AUTH.md", output)
                self.assertEqual("front/src/App.tsx" in output, profile == "fullstack")

    def test_google_compose_and_themes(self):
        for theme in ["light", "dark"]:
            a, _ = scaffold.validate(self.answers(authentication="google", docker=True,
                                                 mongo_mode="compose", frontend_theme=theme))
            output, _ = scaffold.expand(a)
            self.assertEqual(a["mongo_container_uri"], "mongodb://mongo:27017")
            self.assertIn("back/app/api/auth.py", output)
            self.assertIn("mongo-data:/data/db", output["docker-compose.yml"]["body"])
            self.assertIn('data-theme="' + theme + '"', output["front/src/App.tsx"]["body"])
            self.assertIn("--no-access-log", output["build/docker-entrypoint.sh"]["body"])

    def test_external_mongo_keeps_original_topology(self):
        a, _ = scaffold.validate(self.answers(docker=True, mongo_container_uri="mongodb://localhost:27017"))
        output, _ = scaffold.expand(a)
        self.assertNotIn("mongo-data", output["docker-compose.yml"]["body"])

    def test_unsupported_combinations_rejected(self):
        for changes in [dict(authentication="required"), dict(authentication="google", profile="api-root"),
                        dict(mongo_mode="compose"), dict(mongo_mode="unknown"),
                        dict(frontend_theme="dark"), dict(authentication="google", frontend_theme="blue"),
                        dict(worker=True), dict(required_adapters=["sql"]),
                        dict(docker=True, mongo_mode="compose", mongo_container_uri="mongodb://elsewhere:27017")]:
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                scaffold.validate(self.answers(**changes))

    def test_integrity_rejects_modified_output_and_preserves_files(self):
        with tempfile.TemporaryDirectory() as td:
            target = Path(td).resolve() / "project"
            a, _ = scaffold.validate(self.answers(authentication="google"))
            scaffold.generate(target, a)
            scaffold.integrity(target)
            file = target / "front/src/App.tsx"
            file.write_text("user changed this")
            with self.assertRaises(ValueError):
                scaffold.integrity(target)
            with self.assertRaises(ValueError):
                scaffold.generate(target, a)
            self.assertEqual(file.read_text(), "user changed this")

    def test_configure_local_creates_private_env_and_never_overwrites(self):
        with tempfile.TemporaryDirectory() as td:
            target = Path(td).resolve() / "project"
            a, _ = scaffold.validate(self.answers(authentication="google"))
            scaffold.generate(target, a)
            cmd = [sys.executable, str(target / "scripts/configure-local.py"), "--mode", "native"]
            self.assertEqual(subprocess.run(cmd, capture_output=True).returncode, 0)
            env = target / "back/.env"
            original = env.read_bytes()
            self.assertEqual(env.stat().st_mode & 0o777, 0o600)
            self.assertNotEqual(subprocess.run(cmd, capture_output=True).returncode, 0)
            self.assertEqual(env.read_bytes(), original)

    def test_every_template_hash_matches(self):
        for entry in json.loads((ROOT / "assets/template-index.json").read_text()):
            body = (ROOT / "assets" / entry["template"]).read_bytes()
            self.assertEqual(scaffold.digest(body), entry["sha256"], entry["id"])


if __name__ == "__main__":
    unittest.main()
