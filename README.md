# CNVand
[![Snakemake](https://img.shields.io/badge/snakemake-≥8.0.0-brightgreen.svg?style=flat-square)](https://snakemake.bitbucket.io)
[![Conda](https://img.shields.io/badge/conda-≥23.11.0-brightgreen.svg?style=flat-square)](https://anaconda.org/conda-forge/mamba)
![Docker](https://img.shields.io/badge/docker-≥26.1.4-brightgreen.svg?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)

CNVand is a Snakemake pipeline for CNV analysis. Given a set of BAM and VCF files it utilizes the tools `cnvkit` and `AnnotSV` to analyze and annotate them

## General Settings
To configure this pipeline, modify the config under `config/config.yaml` as needed. Detailed explanations for each setting are provided within the file.

## Samplesheet
Add samples to the pipeline by completing `config/samplesheet.tsv`. Each `sample` should be associated with a `path` to the corresponding BAM and VCF file.

## Pipeline Setup
CNVand can be be executed using conda environments or a pre-built docker container.

For AnnotSV to work, the annotation files must be downloaded separately and be referenced in the config file under the respective key. For human annotations, this can be done [here](https://www.lbgi.fr/~geoffroy/Annotations/Annotations_Human_3.4.2.tar.gz). In case this link is not working, check the original [AnnotSV](https://github.com/lgmgeo/AnnotSV/tree/master) repository for updates on how to obtain the annotations.

When using CNVand within the pre-built docker container, it is not needed to download the annotations externally - they come bundled with the container and are available under `data/annotations/`.

### Mamba
For installation and dependency management, Mamba is recommended over conda. Install Snakemake and dependencies using the command `mamba env create -f environment.yml`.

Execute the pipeline with `snakemake --cores all --use-conda`.

Generate a comprehensive execution report by running `snakemake --report report.zip`.

### Docker 

CNVand can also be used inside a docker container. To do so, first pull the docker image with
```docker pull ghcr.io/carlosclassen/cnvand:latest```.

Then run the container with the bind mounts needed in your setup and execute the pipeline inside.