import sys
import os
from cnvizard import vcfMerger

sys.stderr = sys.stdout = open(snakemake.log[0], 'w')
if snakemake.config["params"]["merge_vcf_cnr"]:
    merger = vcfMerger()
    merger.merge_cnr_with_vcf(snakemake.input.bintest_tsv, snakemake.input.vcf, os.path.dirname(snakemake.output.merged_vcf) + "/")
else:
    with open(snakemake.output.merged_vcf, 'w') as f:
        pass