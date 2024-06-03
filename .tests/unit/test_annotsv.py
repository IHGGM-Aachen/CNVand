import os
import sys
import subprocess as sp
from tempfile import TemporaryDirectory
from pathlib import Path, PurePosixPath
import shutil

sys.path.insert(0, os.path.dirname(__file__))

import common

def test_annotsv():
    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/annotsv/data")
        expected_path = PurePosixPath(".tests/unit/annotsv/expected")
        config_path = PurePosixPath(".tests/integration/input/config")
        annotations_path = PurePosixPath("workflow/data/annotations/")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)
        shutil.copytree(config_path, workdir / "config")
        
        # Ensure the annotations directory exists before creating a symlink
        (workdir / "workflow/data").mkdir(parents=True, exist_ok=True)
        os.symlink(Path.cwd() / annotations_path, workdir / "workflow/data/annotations")

        # Print debug information
        print("output/annotsv/M24352.annotated.tsv", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "output/annotsv/M24352.annotated.tsv",
            "-f", 
            "-j1",
            "--target-files-omit-workdir-adjustment",
            "--use-conda",
            "--directory",
            workdir,
        ])

        # Check the output byte by byte using cmp.
        common.OutputChecker(data_path, expected_path, workdir).check()
