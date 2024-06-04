# Workflow Documentation

## Overview

This Snakemake workflow performs copy number variation (CNV) analysis using CNVkit and AnnotSV. The workflow includes steps for preprocessing BAM files, calculating coverage, generating reference models, and annotating variants. The following sections describe each step in detail.

## Rule Graph

<div align="center">
  <img src="images/rulegraph.svg" alt="Rule Graph">
</div>

### Preprocessing

#### `samtools_sort`
- **Description**: Sorts BAM files using Samtools.
- **Input**: BAM file (`get_bam`).
- **Output**: Sorted BAM file (`{sample}.sorted.bam`).
- **Log**: Sorting log (`{sample}.log`).
- **Threads**: 8.
- **Conda Environment**: `../envs/samtools.yaml`.
- **Command**:
  ```bash
  samtools sort -@ {threads} {input} -o {output} > {log} 2>&1
  ```

#### `samtools_index`
- **Description**: Indexes sorted BAM files using Samtools.
- **Input**: Sorted BAM file (`{sample}.sorted.bam`).
- **Output**: BAM index file (`{sample}.sorted.bam.bai`).
- **Log**: Indexing log (`{sample}.log`).
- **Conda Environment**: `../envs/samtools.yaml`.
- **Command**:
  ```bash
  samtools index {input} > {log} 2>&1
  ```

### CNVkit Analysis

#### `cnvkit_target_coverage`
- **Description**: Calculates target coverage using CNVkit.
- **Input**: 
  - BAM file (`{sample}.sorted.bam`).
  - BAM index file (`{sample}.sorted.bam.bai`).
  - Target BED file (`config['ref']['target_bed']`).
- **Output**: Target coverage CNN file (`{sample}.targetcoverage.cnn`).
- **Params**: Extra parameters for CNVkit (`config['params']['cnvkit']['target_coverage']['extra']`).
- **Threads**: 8.
- **Log**: Coverage calculation log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py coverage {input.bam} {input.target_bed} -o {output} -p {threads} {params.extra} > {log} 2>&1
  ```

#### `cnvkit_antitarget_coverage`
- **Description**: Calculates antitarget coverage using CNVkit.
- **Input**: 
  - BAM file (`{sample}.sorted.bam`).
  - BAM index file (`{sample}.sorted.bam.bai`).
  - Antitarget BED file (`config['ref']['antitarget_bed']`).
- **Output**: Antitarget coverage CNN file (`{sample}.antitargetcoverage.cnn`).
- **Params**: Extra parameters for CNVkit (`config['params']['cnvkit']['antitarget_coverage']['extra']`).
- **Threads**: 8.
- **Log**: Coverage calculation log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py coverage {input.bam} {input.antitarget_bed} -o {output} -p {threads} {params.extra} > {log} 2>&1
  ```

#### `cnvkit_reference`
- **Description**: Generates a reference CNN file using CNVkit.
- **Input**: 
  - Target coverage CNN files.
  - Antitarget coverage CNN files.
  - Reference genome FASTA file (`config['ref']['genome']`).
- **Output**: Reference CNN file (`reference.cnn`).
- **Params**: Extra parameters for CNVkit (`config['params']['cnvkit']['reference']['extra']`).
- **Log**: Reference generation log (`cnvkit_reference.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py reference {input.target} {input.antitarget} --fasta {input.ref} -o {output} > {log} 2>&1
  ```

#### `cnvkit_fix`
- **Description**: Corrects CNV calls using CNVkit.
- **Input**: 
  - Target coverage CNN file (`{sample}.targetcoverage.cnn`).
  - Antitarget coverage CNN file (`{sample}.antitargetcoverage.cnn`).
  - Reference CNN file (`reference.cnn`).
- **Output**: CNV regions file (`{sample}.cnr`).
- **Log**: Correction log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py fix {input.target} {input.antitarget} {input.reference} -o {output} > {log} 2>&1
  ```

#### `cnvkit_segment`
- **Description**: Segments CNV regions using CNVkit.
- **Input**: 
  - CNV regions file (`{sample}.cnr`).
  - VCF file (`get_vcf`).
- **Output**: Segmented CNV file (`{sample}.cns`).
- **Params**: Extra parameters for CNVkit (`config['params']['cnvkit']['segment']['extra']`).
- **Threads**: 1 (limited by HMM method).
- **Log**: Segmentation log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py segment -m hmm {input.cnr} -o {output} --vcf {input.vcf} -p {threads} > {log} 2>&1
  ```

#### `cnvkit_call`
- **Description**: Calls CNVs using CNVkit.
- **Input**: 
  - Segmented CNV file (`{sample}.cns`).
  - VCF file (`get_vcf`).
- **Output**: Called CNV file (`{sample}_call.cns`).
- **Params**: Ploidy parameter for CNVkit (`config['params']['cnvkit']['call']['ploidy']`).
- **Log**: Calling log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py call {input.cns} -o {output} -v {input.vcf} --ploidy {params.ploidy} > {log} 2>&1
  ```

#### `cnvkit_bintest`
- **Description**: Performs bin testing using CNVkit.
- **Input**: 
  - CNV regions file (`{sample}.cnr`).
  - Called CNV file (`{sample}_call.cns`).
- **Output**: Bin test results (`{sample}_bintest.tsv`).
- **Log**: Bin test log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py bintest {input.cnr} -s {input.call_cns} --target -o {output} > {log} 2>&1
  ```

#### `cnvkit_breaks`
- **Description**: Identifies CNV breakpoints using CNVkit.
- **Input**: 
  - CNV regions file (`{sample}.cnr`).
  - Segmented CNV file (`{sample}.cns`).
- **Output**: Breakpoints file (`{sample}_breaks.tsv`).
- **Log**: Breakpoints log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py breaks {input.cnr} {input.cns} > {output} 2>&1
  ```

#### `cnvkit_genemetrics`
- **Description**: Generates gene metrics using CNVkit.
- **Input**: 
  - CNV regions file (`{sample}.cnr`).
  - Segmented CNV file (`{sample}.cns`).
- **Output**: Gene metrics file (`{sample}_genemetrics.tsv`).
- **Log**: Gene metrics log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py genemetrics {input.cnr} -s {input.cns} > {output} 2>&1
  ```

#### `cnvkit_scatter_pdf`
- **Description**: Generates a scatter plot in PDF format using CNVkit.
- **Input**: 
  - CNV regions file (`{sample}.cnr`).
 

 - Called CNV file (`{sample}_call.cns`).
  - VCF file (`get_vcf`).
- **Output**: Scatter plot PDF (`{sample}_scatter.pdf`).
- **Log**: Scatter plot log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py scatter {input.cnr} -s {input.call_cns} --y-min -2.5 -v {input.vcf} -o {output} > {log} 2>&1
  ```

#### `cnvkit_scatter_png`
- **Description**: Generates a scatter plot in PNG format using CNVkit.
- **Input**: 
  - CNV regions file (`{sample}.cnr`).
  - Called CNV file (`{sample}_call.cns`).
  - VCF file (`get_vcf`).
- **Output**: Scatter plot PNG (`{sample}_scatter.png`).
- **Log**: Scatter plot log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py scatter {input.cnr} -s {input.call_cns} --y-min -2.5 -v {input.vcf} -o {output} > {log} 2>&1
  ```

#### `cnvkit_export_vcf`
- **Description**: Exports CNV results to VCF format using CNVkit.
- **Input**: Called CNV file (`{sample}_call.cns`).
- **Output**: CNV VCF file (`{sample}_cnv.vcf`).
- **Log**: Export log (`{sample}.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py export vcf {input.call_cns} -i {wildcards.sample} -o {output} > {log} 2>&1
  ```

#### `cnvkit_metrics`
- **Description**: Generates metrics for the CNV analysis run using CNVkit.
- **Input**: 
  - CNV regions files for all samples.
  - Called CNV files for all samples.
- **Output**: Run metrics file (`run_metrics.tsv`).
- **Log**: Metrics log (`cnvkit_metrics.log`).
- **Conda Environment**: `../envs/cnvkit.yaml`.
- **Command**:
  ```bash
  cnvkit.py metrics {input} > {output} 2>&1
  ```

### Annotation

#### `annotsv`
- **Description**: Annotates CNVs using AnnotSV.
- **Input**: CNV VCF file (`{sample}_cnv.vcf`).
- **Output**: Annotated CNV TSV file (`{sample}.annotated.tsv`).
- **Log**: Annotation log (`{sample}.log`).
- **Params**: 
  - Annotations directory (`config['params']['annotsv']['annotations']`).
  - Extra parameters for AnnotSV (`config['params']['annotsv']['extra']`).
- **Conda Environment**: `../envs/annotsv.yaml`.
- **Command**:
  ```bash
  AnnotSV -SVinputFile {input} -annotationsDir {params.annotations} -genomeBuild GRCh38 -outputFile {output} {params.extra} >> {log} 2>&1
  ```

## Inputs and Outputs

### Inputs

- `config/config.yaml`: Configuration file specifying paths and parameters.
- `config/samplesheet.tsv`: Samplesheet with sample information.
- BAM files: Input files for preprocessing.

### Outputs

- Sorted BAM files and their indexes.
- Coverage CNN files for targets and antitargets.
- Reference CNN file.
- CNV regions files.
- Segmented CNV files.
- Called CNV files.
- Bin test results.
- Breakpoints files.
- Gene metrics files.
- Scatter plots in PDF and PNG formats.
- CNV VCF files.
- Annotated CNV TSV files.
- Run metrics file.

## Tools and Dependencies

- [Samtools](http://www.htslib.org/)
- [CNVkit](https://cnvkit.readthedocs.io/en/stable/)
- [AnnotSV](https://lbgi.fr/AnnotSV/)
- Conda environments are defined in the `workflow/envs` directory.

## Testing

The workflow includes integration and unit tests located in the `.tests` directory.

- `.tests/integration`: Contains input data, configuration specifications, and shell commands for integration testing.
- `.tests/unit`: Contains subdirectories dedicated to testing each separate workflow step independently.

## Additional Information

For more details, please refer to the README.md file and the project repository.