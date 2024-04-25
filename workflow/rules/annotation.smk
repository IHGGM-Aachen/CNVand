rule annotsv:
    input:
        os.path.join(config['outdir'], 'cnv', '{sample}', '{sample}_cnv.vcf')
    output:
        os.path.join(config['outdir'], 'annotsv', '{sample}.annotated.tsv')
    log: 
        os.path.join(config['outdir'], 'logs', 'annotsv', '{sample}.log')
    params:
        refGene="http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/ncbiRefSeq.txt.gz",
        extra=config['params']['annotsv']['extra']
    conda:
        "../envs/annotsv.yaml"
    shell:
        """
        wget -O /tmp/Annotations_Human/Genes/GRCh38/refGene.txt.gz {params.refGene} > {log} 2>&1
        AnnotSV -SVinputFile {input} -annotationsDir /tmp -genomeBuild GRCh38 -outputFile {output} >> {log} 2>>&1
        """
    
