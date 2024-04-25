# CNVand
[![Snakemake](https://img.shields.io/badge/snakemake-≥7.16.0-brightgreen.svg?style=flat-square)](https://snakemake.bitbucket.io)
[![Conda](https://img.shields.io/badge/conda-≥23.1.0-brightgreen.svg?style=flat-square)](https://anaconda.org/conda-forge/mamba)
![Docker](https://img.shields.io/badge/docker-≥20.10.7-brightgreen.svg?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)

CNVand is a Snakemake pipeline for CNV analysis. Given a set of BAM and VCF files it utilizes the tools `cnvkit` and `AnnotSV` to analyze and annotate them

## General Settings
To configure this pipeline, modify the config under `config/config.yaml` as needed. Detailed explanations for each setting are provided within the file.

## Samplesheet
Add samples to the pipeline by completing `config/samplesheet.tsv`. Each `sample` should be associated with a `path` to the corresponding BAM and VCF file.

## Pipeline Execution
CNVand can be only be executed using conda environments for the moment.

### Mamba
For installation and dependency management, Mamba is recommended. Install Snakemake and dependencies using the command `mamba env create -f environment.yml`.

Execute the pipeline with `snakemake --cores all --use-conda`.

Generate a comprehensive execution report by running `snakemake --report report.zip`.