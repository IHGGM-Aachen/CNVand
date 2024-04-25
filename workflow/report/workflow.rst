Variants where analyzed and annotated following the `CNVand Workflow`_:

1. **CNV Detection with CNVkit:**
   - Target and antitarget coverage calculations were performed using CNVkit. For target regions, additional parameters included `{{ snakemake.config["params"]["cnvkit"]["target_coverage"]["extra"] }}`, and for antitarget regions, `{{ snakemake.config["params"]["cnvkit"]["antitarget_coverage"]["extra"] }}`.
   - A reference panel was generated from the target and antitarget coverage data of all samples to normalize CNV detection.
   - The `fix` command in CNVkit was used to combine the target and antitarget coverages with the reference, correcting for systematic biases to produce corrected copy number ratios.
   - CNV segmentation was then conducted to identify distinct CNV events within each sample.
   - Each CNV event was called to classify copy number states.

2. **CNV Annotation:**
   - Annotated structural variant data was generated using AnnotSV, which was configured to utilize the reference gene annotations from `{{ snakemake.config["params"]["annotsv"]["refGene"] }}`.
   - The output includes detailed annotations of CNVs with respect to known gene locations and potential functional impacts.