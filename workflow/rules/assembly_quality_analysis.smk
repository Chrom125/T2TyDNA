rule mummerplot:
    """
    This rule is to check the quality of the assembly.
    Basically, the rule plot the assembly against a reference genome. If everything is going well, we have a beautiful straight line
    of the form y = x in bright red.
    """
    input:
        assembly = "results/{sample}/{sample}_genome_ordered.fa",
        reference = "ressources/rep/BY.asm01.HP0.nuclear_genome.tidy.fa"
    output:
        "results/{sample}/nucmer_results/nucmer.png"
    conda:
        "t2tydna"
    log:
        "results/{sample}/logs/{sample}_mummerplot/log"
    shell:
        """
        mkdir -p results/{wildcards.sample}/nucmer_results
        nucmer -p results/{wildcards.sample}/nucmer_results/nucmer {input.reference} {input.assembly}
        delta-filter -1 results/{wildcards.sample}/nucmer_results/nucmer.delta > results/{wildcards.sample}/nucmer_results/nucmer.delta_filter
        mummerplot --large --color --png results/{wildcards.sample}/nucmer_results/nucmer.delta_filter -p results/{wildcards.sample}/nucmer_results/nucmer
        """

rule busco:
    """
    Busco is a tool to check the quality of the assembly.
    It is looking for genes commonly found in species like S. cerevisiae.
    If he found them all or almost them all, it is very good !
    I often get something like more than 99% of them.
    """
    input:
        assembly = "results/{sample}/{sample}_genome_ordered.fa"
    output:
        directory("results/{sample}/busco_results")
    conda:
        "busco"
    log:
        "results/{sample}/logs/{sample}_busco.log"
    threads:
        16
    shell:
        "busco -f -i {input.assembly} -m genome -l saccharomycetaceae_odb12 -c {threads} -o results/{wildcards.sample}/busco_results"

rule quast:
    """
    Quast is a tool to check the quality of the assembly.
    It gives you statistics like N50 (You take the sum from the largest reads to the shortest and you add them until you reach half of the assembly.
    When you reach half, you take the length of the last reads taken.), L50 but also number of mismatch and everything.
    For now, I have like 20 mismatches usually. I don't know if it's normal.
    """
    input:
        assembly = "results/{sample}/{sample}_genome_ordered.fa",
        reference = "ressources/rep/BY.asm01.HP0.nuclear_genome.tidy.fa"
    output:
        "results/{sample}/quast_result/report.pdf"
    conda:
        "test"
    log:
        "results/{sample}/logs/{sample}_quast_report.log"
    shell:
        "quast {input.assembly} -r {input.reference} -o results/{wildcards.sample}/quast_result"