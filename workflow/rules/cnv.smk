rule cnvkit_target_coverage:
    input:
        bam=os.path.join(config["outdir"], "preprocessing", "{sample}.sorted.bam"),
        bai=os.path.join(config["outdir"], "preprocessing", "{sample}.sorted.bam.bai"),
        target_bed=config["ref"]["target_bed"],
    output:
        os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.targetcoverage.cnn"),
    params:
        extra=config["params"]["cnvkit"]["target_coverage"]["extra"],
    threads: 8
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_target_coverage", "{sample}.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py coverage {input.bam} {input.target_bed} -o {output} -p {threads} {params.extra} > {log} 2>&1"


rule cnvkit_antitarget_coverage:
    input:
        bam=os.path.join(config["outdir"], "preprocessing", "{sample}.sorted.bam"),
        bai=os.path.join(config["outdir"], "preprocessing", "{sample}.sorted.bam.bai"),
        antitarget_bed=config["ref"]["antitarget_bed"],
    output:
        os.path.join(
            config["outdir"], "cnv", "{sample}", "{sample}.antitargetcoverage.cnn"
        ),
    params:
        extra=config["params"]["cnvkit"]["antitarget_coverage"]["extra"],
    threads: 8
    log:
        os.path.join(
            config["outdir"], "logs", "cnvkit_antitarget_coverage", "{sample}.log"
        ),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py coverage {input.bam} {input.antitarget_bed} -o {output} -p {threads} {params.extra} > {log} 2>&1"


rule cnvkit_reference:
    input:
        target=collect(
            os.path.join(
                config["outdir"], "cnv", "{sample}", "{sample}.targetcoverage.cnn"
            ),
            sample=SAMPLES.index,
        ),
        antitarget=collect(
            os.path.join(
                config["outdir"], "cnv", "{sample}", "{sample}.antitargetcoverage.cnn"
            ),
            sample=SAMPLES.index,
        ),
        ref=config["ref"]["genome"],
    output:
        os.path.join(config["outdir"], "cnv", "reference.cnn"),
    params:
        extra=config["params"]["cnvkit"]["reference"]["extra"],
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_reference.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py reference {input.target} {input.antitarget} --fasta {input.ref} -o {output} > {log} 2>&1"


rule cnvkit_fix:
    input:
        target=os.path.join(
            config["outdir"], "cnv", "{sample}", "{sample}.targetcoverage.cnn"
        ),
        antitarget=os.path.join(
            config["outdir"], "cnv", "{sample}", "{sample}.antitargetcoverage.cnn"
        ),
        reference=os.path.join(config["outdir"], "cnv", "reference.cnn"),
    output:
        os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cnr"),
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_fix", "{sample}.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py fix {input.target} {input.antitarget} {input.reference} -o {output} > {log} 2>&1"


rule cnvkit_segment:
    input:
        cnr=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cnr"),
        vcf=get_vcf,
    output:
        temp(os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cns")),
    params:
        extra=config["params"]["cnvkit"]["segment"]["extra"],
    threads: 1  # Limited by HMM method
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_segment", "{sample}.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py segment -m hmm {input.cnr} -o {output} --vcf {input.vcf} -p {threads} > {log} 2>&1"


rule cnvkit_call:
    input:
        cns=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cns"),
        vcf=get_vcf,
    output:
        os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_call.cns"),
    params:
        ploidy=config["params"]["cnvkit"]["call"]["ploidy"],
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_call", "{sample}.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py call {input.cns} -o {output} -v {input.vcf} --ploidy {params.ploidy} > {log} 2>&1"


rule cnvkit_bintest:
    input:
        cnr=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cnr"),
        call_cns=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_call.cns"),
    output:
        os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_bintest.tsv"),
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_bintest", "{sample}.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py bintest {input.cnr} -s {input.call_cns} --target -o {output} > {log} 2>&1"


rule cnvkit_breaks:
    input:
        cnr=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cnr"),
        cns=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cns"),
    output:
        os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_breaks.tsv"),
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_breaks", "{sample}.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py breaks {input.cnr} {input.cns} > {output} 2>&1"


rule cnvkit_genemetrics:
    input:
        cnr=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cnr"),
        cns=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cns"),
    output:
        os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_genemetrics.tsv"),
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_genemetrics", "{sample}.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py genemetrics {input.cnr} -s {input.cns} > {output} 2>&1"


rule cnvkit_scatter_pdf:
    input:
        cnr=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cnr"),
        call_cns=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_call.cns"),
        vcf=get_vcf,
    output:
        os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_scatter.pdf"),
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_scatter_pdf", "{sample}.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py scatter {input.cnr} -s {input.call_cns} --y-min -2.5 -v {input.vcf} -o {output} > {log} 2>&1"


rule cnvkit_scatter_png:
    input:
        cnr=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cnr"),
        call_cns=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_call.cns"),
        vcf=get_vcf,
    output:
        os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_scatter.png"),
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_scatter_png", "{sample}.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py scatter {input.cnr} -s {input.call_cns} --y-min -2.5 -v {input.vcf} -o {output} > {log} 2>&1"


rule cnvkit_export_vcf:
    input:
        call_cns=os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_call.cns"),
    output:
        os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_cnv.vcf"),
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_export_vcf", "{sample}.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py export vcf {input.call_cns} -i {wildcards.sample} -o {output} > {log} 2>&1"


rule cnvkit_metrics:
    input:
        expand(
            os.path.join(config["outdir"], "cnv", "{sample}", "{sample}.cnr"),
            sample=SAMPLES.index,
        ),
        expand(
            os.path.join(config["outdir"], "cnv", "{sample}", "{sample}_call.cns"),
            sample=SAMPLES.index,
        ),
    output:
        os.path.join(config["outdir"], "cnv", "run_metrics.tsv"),
    log:
        os.path.join(config["outdir"], "logs", "cnvkit_metrics.log"),
    conda:
        "../envs/cnvkit.yaml"
    shell:
        "cnvkit.py metrics {input} > {output} 2>&1"
