rule repeatmasker:
    input:
        "results/{sample}/{sample}_genome_ordered.fa"
    output:
        "results/{sample}/{sample}_genome_ordered.fa.out"
    log:
        "results/{sample}/logs/{sample}_repeatmasker.log"
    threads: 4
    shadow: "minimal"
    conda:
        "repeatmasker"
    shell:
        """
        RepeatMasker -lib ../../../ressources/misc/library.fa -engine rmblast -pa {threads} {input}
        """