import os
import sys
import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath

sys.path.insert(0, os.path.dirname(__file__))

import common

def test_samtools_sort():

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/samtools_sort/data")
        expected_path = PurePosixPath(".tests/unit/samtools_sort/expected")
        config_path = PurePosixPath(".tests/integration/input/config")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)
        shutil.copytree(config_path, workdir / "config")

        # dbg
        print("output/preprocessing/M24352.sorted.bam", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "output/preprocessing/M24352.sorted.bam",
            "-f", 
            "-j1",
            "--target-files-omit-workdir-adjustment",
            "--use-conda",
            "--directory",
            workdir,
        ])

        # Define paths for generated and expected files
        generated_file = workdir / "output/preprocessing/M24352.sorted.bam"
        expected_file = Path(expected_path) / "output/preprocessing/M24352.sorted.bam"

        # Check the output using samtools for BAM files
        sp.check_output(["samtools", "quickcheck", generated_file, expected_file])