# Changelog

## [0.1] - 04/06/2024
Initial release of the CNVand pipeline.

### Added
- CNV detection using CNVkit with target and antitarget coverage calculations, reference panel generation, systematic bias correction, CNV segmentation, and CNV calling.
- CNV visualization with scatter plot generation in PDF and PNG formats.
- Annotation using AnnotSV with reference gene annotations.
- Docker support for pipeline execution in an isolated environment.
- Snakedeploy support for quick installation.
- Automated HTML report generation with Snakemake.

## [0.2] - 05/06/2024
Minor changes in documentation and GitHub actions

### Changed
- GitHub workflow description under `.github/workflows/dockerize.yml` to exclude annotation bundling.
- Mamba `environment.yml` file to set up an environment with the name 'cnvand'.
- Main `README.md` to adapt to the former changes and to link to other documentation inside the repository.
