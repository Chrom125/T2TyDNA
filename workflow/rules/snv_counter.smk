rule mapping_all:
    input:
        reads = "results/{sample}/{sample}_filtered.fastq",
        assembly = "results/{sample}/{sample}_genome_ordered.fa"
    output:
        "results/{sample}/{sample}_mapped.sam"
    conda:
        "t2tydna"
    log:
        "results/{sample}/logs/{sample}_assembly.log"
    threads: 8
    shell:
        "minimap2 --eqx -ax map-ont -t {threads} {input.assembly} {input.reads} > {output} 2>{log}"

rule mpileup_convert:
    input:
        "results/{sample}/{sample}_mapped.sam"
    output:
        "results/{sample}/{sample}_mapped.pileup"
    conda:
        "snv_counter"
    shell:
        "samtools mpileup -B -A -f [index-dir]/chr16.fa  [path/to/bam-file] > [path/to/mpileup-file]"

rule varscan:
    input:
        "results/{sample}/{sample}_mapped.pileup"
    output:
        "results/{sample}/{sample}_"
    shell:
        "varscan somatic [path/to/normal-pileup-file] [path/to/tumor-pileup-file] [path/to/output-basename]"

rule snv_counter:
    input:
        assembly = expand("results/{sample}/{sample}_genome.fa", sample = samples),
        mapping = expand("results/{sample}/{sample}_mapped.sam", sample = samples)
    output:
        "{sample}_snv_table.csv"
    log:
        "results/{sample}/logs/{sample}_snv_count.log"
