import os
import sys
import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath
from pdf2image import convert_from_path
from PIL import ImageChops, Image

sys.path.insert(0, os.path.dirname(__file__))

import common


def test_cnvkit_scatter_pdf():

    def images_are_equal(img1, img2):
        diff = ImageChops.difference(img1, img2)
        if diff.getbbox():
            return False
        return True

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/cnvkit_scatter_pdf/data")
        expected_path = PurePosixPath(".tests/unit/cnvkit_scatter_pdf/expected")
        config_path = PurePosixPath(".tests/integration/input/config")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)
        shutil.copytree(config_path, workdir / "config")

        # dbg
        print("output/cnv/M24352/M24352_scatter.pdf", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "output/cnv/M24352/M24352_scatter.pdf",
            "-f", 
            "-j1",
            "--target-files-omit-workdir-adjustment",
            "--use-conda",
            "--directory",
            workdir,
        ])

        # Convert generated and expected PDFs to images
        generated_file = workdir / "output/cnv/M24352/M24352_scatter.pdf"
        expected_file = expected_path / "output/cnv/M24352/M24352_scatter.pdf"
        generated_images = convert_from_path(generated_file)
        expected_images = convert_from_path(expected_file)

        # Compare the number of pages
        assert len(generated_images) == len(expected_images), "PDF page count differs"

        # Compare each page
        for i in range(len(generated_images)):
            assert images_are_equal(generated_images[i], expected_images[i]), f"PDF page {i+1} differs"