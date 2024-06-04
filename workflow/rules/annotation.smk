rule annotsv:
    input:
        os.path.join(config['outdir'], 'cnv', '{sample}', '{sample}_cnv.vcf'),
    output:
        report(
            os.path.join(config['outdir'], 'annotsv', '{sample}.annotated.tsv'),
            caption=os.path.join(snakedir, "report/workflow.rst"),
            category="CNV Annotation"
        ),
    log:
        os.path.join(config['outdir'], 'logs', 'annotsv', '{sample}.log'),
    params:
        annotations=config['params']['annotsv']['annotations'],  # Path to the pre-downloaded annotations
        extra=config['params']['annotsv']['extra']
    conda:
        "../envs/annotsv.yaml"
    shell:
        """
        AnnotSV -SVinputFile {input} -annotationsDir {params.annotations} -genomeBuild GRCh38 -outputFile {output} {params.extra} >> {log} 2>&1
        """
