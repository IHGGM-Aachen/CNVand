import os
import sys

import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath

sys.path.insert(0, os.path.dirname(__file__))

import common


def test_cnvkit_reference():

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/cnvkit_reference/data")
        expected_path = PurePosixPath(".tests/unit/cnvkit_reference/expected")
        config_path = PurePosixPath(".tests/integration/input/config")
        reference_path = PurePosixPath("workflow/resources/")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)
        shutil.copytree(config_path, workdir / "config")

        # Ensure the directory structure exists before creating the symlink
        (workdir / "workflow").mkdir(parents=True, exist_ok=True)
        os.symlink(Path.cwd() / reference_path, workdir / "workflow/resources")


        # dbg
        print("output/cnv/reference.cnn", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "output/cnv/reference.cnn",
            "-f", 
            "-j1",
            "--target-files-omit-workdir-adjustment",
    
            "--use-conda",
            "--directory",
            workdir,
        ])

        # Check the output byte by byte using cmp.
        common.OutputChecker(data_path, expected_path, workdir).check()
