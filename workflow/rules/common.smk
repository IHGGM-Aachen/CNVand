import pandas as pd
from snakemake.utils import validate
from snakemake.utils import min_version

min_version("8.12.0")


report: "../report/workflow.rst"


snakedir = workflow.basedir


###### Config file and sample sheets #####
configfile: "config/config.yaml"


SAMPLES = pd.read_table(config["samples"]).set_index("sample", drop=False)

snakedir = workflow.basedir

##### Validation #####
validate(config, schema="../schemas/config.schema.yaml")
validate(SAMPLES, schema="../schemas/samplesheet.schema.yaml")


##### Helper functions #####


def get_bam(wildcards):
    """Retrieve BAM file for a given sample."""
    return SAMPLES.loc[wildcards.sample, "bam_path"]


def get_vcf(wildcards):
    """Retrieve VCF file for a given sample."""
    return SAMPLES.loc[wildcards.sample, "vcf_path"]

def get_input_for_annotsv(wildcards):
    if config.get("merge_vcf_cnr", True):
        return os.path.join(config["outdir"], "cnv", wildcards.sample, f"{wildcards.sample}_merged.vcf")
    else:
        return os.path.join(config["outdir"], "cnv", wildcards.sample, f"{wildcards.sample}_cnv.vcf")
