# CNVand Configuration Instructions

## Configuration File

The configuration file (`config/config.yaml`) contains various settings that the CNVand pipeline requires. Below is an example of a typical configuration file along with an explanation of each parameter.

### Example Configuration File

```yaml
### Samplesheet
samples: config/samplesheet.tsv

### Output directory
outdir: output/

### Reference data
ref:
  genome: workflow/resources/Homo_sapiens_assembly38.fasta # Take care you're using the same reference in your full workflow
  target_bed: .tests/integration/input/target.bed
  antitarget_bed: .tests/integration/input/antitarget.bed

### Toolkit parameter settings
params:
  cnvkit:
    target_coverage:
      extra: "-q 20"
    antitarget_coverage:
      extra: "-q 20"
    reference:
      extra: ""
    call:
      ploidy: 2
      extra: "" 
    bintest:
      extra: "" 
    breaks:
      extra: "" 
    genemetrics:
      extra: "" 
    scatter:
      y_min: "-2.5"
      extra: "" 
    export_vcf:
      extra: "" 
    segment:
      extra: ""
  annotsv:
    annotations: "workflow/data/annotations/" # Annotations to be downloaded externally - see README.md for more details
    extra: ""
```

### Parameter Explanations

#### Samplesheet
- **samples**: Path to the samplesheet file that contains information about the samples to be processed. This should be set to `config/samplesheet.tsv`.

#### Output Directory
- **outdir**: Path to the directory where the output files will be stored. This is set to `output/`.

#### Reference Data
- **ref**: 
  - **genome**: Path to the reference genome file. Ensure that the reference genome used here is consistent throughout your workflow. Example: `workflow/resources/Homo_sapiens_assembly38.fasta`.
  - **target_bed**: Path to the target BED file. Example: `.tests/integration/input/target.bed`.
  - **antitarget_bed**: Path to the antitarget BED file. Example: `.tests/integration/input/antitarget.bed`.

#### Toolkit Parameter Settings
- **params**:
  - **cnvkit**: Parameters for CNVkit tools.
    - **target_coverage**: Additional parameters for target coverage calculations. Example: `-q 20`.
    - **antitarget_coverage**: Additional parameters for antitarget coverage calculations. Example: `-q 20`.
    - **reference**: Additional parameters for reference generation.
    - **call**: Parameters for CNV calling.
      - **ploidy**: Ploidy level to be used. Example: `2`.
      - **extra**: Additional parameters for the call step.
    - **bintest**: Additional parameters for bin testing.
    - **breaks**: Additional parameters for breakpoints detection.
    - **genemetrics**: Additional parameters for gene metrics calculation.
    - **scatter**: Parameters for scatter plot generation.
      - **y_min**: Minimum y-axis value for scatter plots. Example: `-2.5`.
      - **extra**: Additional parameters for scatter plots.
    - **export_vcf**: Additional parameters for VCF export.
    - **segment**: Additional parameters for segmentation.
  - **annotsv**: Parameters for AnnotSV tool.
    - **annotations**: Path to the directory containing annotation files. Example: `workflow/data/annotations/`.
    - **extra**: Additional parameters for AnnotSV.

## Samplesheet

The samplesheet (`config/samplesheet.tsv`) contains information about the samples to be processed by the CNVand pipeline. It includes the sample name, path to the BAM file, and path to the VCF file.

### Example Samplesheet

```tsv
sample  bam_path                                vcf_path
M24352  .tests/integration/input/M24352_CHR21.bam  .tests/integration/input/M24352_CHR21.vcf.gz
```

### Column Explanations
- **sample**: Unique identifier for the sample. Example: `M24352`.
- **bam_path**: Path to the BAM file for the sample. Example: `.tests/integration/input/M24352_CHR21.bam`.
- **vcf_path**: Path to the VCF file for the sample. Example: `.tests/integration/input/M24352_CHR21.vcf.gz`.

## Summary

1. **Configuration File**: Ensure all paths and parameters are correctly set in the `config/config.yaml` file.
2. **Samplesheet**: Ensure the `config/samplesheet.tsv` file contains accurate paths to the BAM and VCF files for each sample.

By following these instructions, you will set up the CNVand pipeline correctly, ensuring accurate CNV analysis and annotation.