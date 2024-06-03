import os
import sys
import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath
from PIL import ImageChops, Image

sys.path.insert(0, os.path.dirname(__file__))

import common


def test_cnvkit_scatter_png():

    def images_are_equal(img1, img2):
        diff = ImageChops.difference(img1, img2)
        if diff.getbbox():
            return False
        return True

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/cnvkit_scatter_png/data")
        expected_path = PurePosixPath(".tests/unit/cnvkit_scatter_png/expected")
        config_path = PurePosixPath(".tests/integration/input/config")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)
        shutil.copytree(config_path, workdir / "config")

        # dbg
        print("output/cnv/M24352/M24352_scatter.png", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "output/cnv/M24352/M24352_scatter.png",
            "-f", 
            "-j1",
            "--target-files-omit-workdir-adjustment",
            "--use-conda",
            "--directory",
            workdir,
        ])

        # Compare generated and expected PNGs
        generated_file = workdir / "output/cnv/M24352/M24352_scatter.png"
        expected_file = expected_path / "output/cnv/M24352/M24352_scatter.png"
        
        generated_image = Image.open(generated_file)
        expected_image = Image.open(expected_file)

        assert images_are_equal(generated_image, expected_image), "PNG images differ"
