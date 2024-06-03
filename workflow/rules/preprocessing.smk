rule samtools_sort:
    input:
        get_bam,
    output:
        os.path.join(config["outdir"], "preprocessing", "{sample}.sorted.bam"),
    log:
        os.path.join(config["outdir"], "logs", "samtools_sort", "{sample}.log"),
    threads: 8
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools sort -@ {threads} {input} -o {output} > {log} 2>&1"


rule samtools_index:
    input:
        os.path.join(config["outdir"], "preprocessing", "{sample}.sorted.bam"),
    output:
        os.path.join(config["outdir"], "preprocessing", "{sample}.sorted.bam.bai"),
    log:
        os.path.join(config["outdir"], "logs", "samtools_index", "{sample}.log"),
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools index {input} > {log} 2>&1"
