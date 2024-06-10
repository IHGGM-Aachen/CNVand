FROM condaforge/mambaforge:latest

# Step 1: Copy the entire repository
COPY . /cnvand

# Step 2: Set the working directory
WORKDIR /cnvand

# Step 3: Install the base environment using environment.yml
COPY environment.yml /cnvand/environment.yml
RUN mamba env update --name base --file /cnvand/environment.yml && \
    mamba clean --all -y

# Step 4: Ensure bash is available and set as the entrypoint
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
