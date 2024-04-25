# Import Mamba Base Image
FROM mambaorg/micromamba:1.4.2

# Define Workdir
WORKDIR /pipeline

# Configure Conda Environment
COPY --chown=$MAMBA_USER:$MAMBA_USER . .
RUN micromamba install -y -n base -f ./Environment.yml && \
    micromamba clean --all --yes

# Make RUN commands use the new environment:
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Set entrypoint command
ENTRYPOINT ["snakemake", "--use-conda", "--cores all"]
