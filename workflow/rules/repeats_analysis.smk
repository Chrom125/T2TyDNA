rule repeatmasker:
    input:
        "results/{sample}/{sample}_genome_ordered.fa"
    output:
        "results/{sample}/{sample}_genome_ordered.fa.out.gff"
    log:
        "results/{sample}/logs/{sample}_repeatmasker.log"
    threads: 4
    shadow: "minimal"
    conda:
        "repeatmasker"
    shell:
        """
        pwd
        RepeatMasker -lib ../../../ressources/misc/library.fa -nolow -engine rmblast -gff -pa {threads} {input}
        """
    
rule repeatcounting:
    input:
        expand("results/{sample}/{sample}_genome_ordered.fa.out.gff", sample = samples)
    output:
        "results/common/repeat_number.csv"
    conda:
        "test"
    script:
        "../scr/repeat_counter.py"