import os
import sys
import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath

sys.path.insert(0, os.path.dirname(__file__))

import common

def test_cnvkit_export_vcf():
    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/cnvkit_export_vcf/data")
        expected_path = PurePosixPath(".tests/unit/cnvkit_export_vcf/expected")
        config_path = PurePosixPath(".tests/integration/input/config")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)
        shutil.copytree(config_path, workdir / "config")

        # Print debug information
        print("output/cnv/M24352/M24352_cnv.vcf", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "output/cnv/M24352/M24352_cnv.vcf",
            "-f", 
            "-j1",
            "--target-files-omit-workdir-adjustment",
            "--use-conda",
            "--directory",
            workdir,
        ])

        # Check the output byte by byte using cmp.
        common.OutputChecker(data_path, expected_path, workdir).check()
