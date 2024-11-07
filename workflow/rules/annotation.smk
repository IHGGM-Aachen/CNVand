rule annotsv:
    input:
        get_input_for_annotsv,
    output:
        report(
            os.path.join(config["outdir"], "annotsv", "{sample}.annotated.tsv"),
            caption="../report/workflow.rst",
            category="CNV Annotation",
        ),
    log:
        os.path.join(config["outdir"], "logs", "annotsv", "{sample}.log"),
    params:
        annotations=config["params"]["annotsv"]["annotations"],  # Path to the pre-downloaded annotations
        extra=config["params"]["annotsv"]["extra"] + (" -SVminSize 0" if config["params"]["merge_vcf_cnr"] else ""),
    conda:
        "../envs/annotsv.yaml"
    shell:
        """
        AnnotSV -SVinputFile {input} -annotationsDir {params.annotations} -genomeBuild GRCh38 -outputFile {output} {params.extra} >> {log} 2>&1
        """
