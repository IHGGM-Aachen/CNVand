FROM condaforge/mambaforge:latest
LABEL io.github.snakemake.containerized="true"
LABEL io.github.snakemake.conda_env_hash="5b5ad0e59eaba768b350d514ecc353effb1f81be3e37252680f1c43583c67609"

# Step 1: Copy the entire repository
COPY . /cnvand

# Step 2: Retrieve conda environments

# Conda environment:
#   source: workflow/envs/annotsv.yaml
#   prefix: /conda-envs/9280efb5061f79303f2740a69567fc1f
#   channels:
#     - conda-forge
#     - bioconda
#   dependencies:
#     - annotsv == 3.4.2
RUN mkdir -p /conda-envs/9280efb5061f79303f2740a69567fc1f
COPY workflow/envs/annotsv.yaml /conda-envs/9280efb5061f79303f2740a69567fc1f/environment.yaml

# Conda environment:
#   source: workflow/envs/cnvkit.yaml
#   prefix: /conda-envs/f450dca2c0c735656015003c50d1723b
#   channels:
#     - conda-forge
#     - bioconda
#   dependencies:
#     - cnvkit == 0.9.11 
#     - pomegranate >= 0.7.7
RUN mkdir -p /conda-envs/f450dca2c0c735656015003c50d1723b
COPY workflow/envs/cnvkit.yaml /conda-envs/f450dca2c0c735656015003c50d1723b/environment.yaml

# Conda environment:
#   source: workflow/envs/samtools.yaml
#   prefix: /conda-envs/5beded926fd4a058ca1dca3286279d88
#   channels:
#     - conda-forge
#     - bioconda
#   dependencies:
#     - samtools
RUN mkdir -p /conda-envs/5beded926fd4a058ca1dca3286279d88
COPY workflow/envs/samtools.yaml /conda-envs/5beded926fd4a058ca1dca3286279d88/environment.yaml

# Step 3: Generate conda environments

RUN mamba env create --prefix /conda-envs/9280efb5061f79303f2740a69567fc1f --file /conda-envs/9280efb5061f79303f2740a69567fc1f/environment.yaml && \
    mamba env create --prefix /conda-envs/f450dca2c0c735656015003c50d1723b --file /conda-envs/f450dca2c0c735656015003c50d1723b/environment.yaml && \
    mamba env create --prefix /conda-envs/5beded926fd4a058ca1dca3286279d88 --file /conda-envs/5beded926fd4a058ca1dca3286279d88/environment.yaml && \
    mamba clean --all -y

# Set the working directory
WORKDIR /cnvand

# Set entrypoint to bash
ENTRYPOINT ["/bin/bash"]
