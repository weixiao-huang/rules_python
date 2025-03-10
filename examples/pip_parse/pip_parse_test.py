#!/usr/bin/env python3

import os
import subprocess
import unittest
from pathlib import Path

from rules_python.python.runfiles import runfiles


class PipInstallTest(unittest.TestCase):
    maxDiff = None

    def test_entry_point(self):
        env = os.environ.get("YAMLLINT_ENTRY_POINT")
        self.assertIsNotNone(env)

        r = runfiles.Create()

        # To find an external target, this must use `{workspace_name}/$(rootpath @external_repo//:target)`
        entry_point = Path(r.Rlocation("rules_python_pip_parse_example/{}".format(env)))
        self.assertTrue(entry_point.exists())

        proc = subprocess.run(
            [str(entry_point), "--version"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        self.assertEqual(proc.stdout.decode("utf-8").strip(), "yamllint 1.26.3")

    def test_data(self):
        env = os.environ.get("WHEEL_DATA_CONTENTS")
        self.assertIsNotNone(env)
        self.assertListEqual(
            env.split(" "),
            [
                "external/pypi_s3cmd/s3cmd-2.1.0.data/data/share/doc/packages/s3cmd/INSTALL.md",
                "external/pypi_s3cmd/s3cmd-2.1.0.data/data/share/doc/packages/s3cmd/LICENSE",
                "external/pypi_s3cmd/s3cmd-2.1.0.data/data/share/doc/packages/s3cmd/NEWS",
                "external/pypi_s3cmd/s3cmd-2.1.0.data/data/share/doc/packages/s3cmd/README.md",
                "external/pypi_s3cmd/s3cmd-2.1.0.data/data/share/man/man1/s3cmd.1",
                "external/pypi_s3cmd/s3cmd-2.1.0.data/scripts/s3cmd",
            ],
        )

    def test_dist_info(self):
        env = os.environ.get("WHEEL_DIST_INFO_CONTENTS")
        self.assertIsNotNone(env)
        self.assertListEqual(
            env.split(" "),
            [
                "external/pypi_requests/requests-2.25.1.dist-info/LICENSE",
                "external/pypi_requests/requests-2.25.1.dist-info/METADATA",
                "external/pypi_requests/requests-2.25.1.dist-info/RECORD",
                "external/pypi_requests/requests-2.25.1.dist-info/WHEEL",
                "external/pypi_requests/requests-2.25.1.dist-info/top_level.txt",
            ],
        )


if __name__ == "__main__":
    unittest.main()
