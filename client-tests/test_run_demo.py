import importlib.util
import os
from pathlib import Path
import sys
import unittest
from unittest.mock import patch


def load_run_demo():
    module_path = Path(__file__).with_name("run_demo.py")
    spec = importlib.util.spec_from_file_location("run_demo_under_test", module_path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


run_demo = load_run_demo()


class GitRevisionTest(unittest.TestCase):

    def test_uses_environment_fallback_when_git_is_unavailable(self):
        with patch.dict(os.environ, {"GIT_REVISION": "image-revision"}, clear=False):
            with patch.object(run_demo.subprocess, "run", side_effect=FileNotFoundError):
                self.assertEqual("image-revision", run_demo.git_revision(Path("/app")))

    def test_uses_explicit_container_fallback_without_git_or_environment(self):
        with patch.dict(os.environ, {}, clear=True):
            with patch.object(run_demo.subprocess, "run", side_effect=FileNotFoundError):
                self.assertEqual("container-demo", run_demo.git_revision(Path("/app")))


if __name__ == "__main__":
    unittest.main()
