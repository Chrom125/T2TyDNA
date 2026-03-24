rule coverage:
    input:
        mapping = "results/{sample}/{sample}_mapped.bam",
        index = "results/{sample}/{sample}_mapped.bam.bai"
    output:
        temp("results/{sample}/{sample}_coverage_depth.tsv")
    conda:
        "base"
    shell:
        "samtools depth -a {input.mapping} > {output}"

rule plot_coverage:
    input:
        "results/{sample}/{sample}_coverage_depth.tsv"
    output:
        "results/{sample}/coverage_bp.png"
    conda:
        "test"
    script:
        "../scr/coverage_by_chromosome.py"