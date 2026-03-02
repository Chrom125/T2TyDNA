samples, = glob_wildcards("data/{sample}.fastq.gz")

rule all:
    input:
        #expand("results/{sample}_mapped.sam", sample=samples),
        #"results/Filtred_Results.csv"
        expand("results/{sample}_tel_len.png", sample = samples),


rule filtlong:
    input:
        "data/{sample}.fastq.gz"
    output:
        temp("results/{sample}_filtered.fastq")
    conda:
        "t2tydna"
    log:
        "logs/{sample}_filtlong.log"
    shell:
        "filtlong --min_length 1000 --keep_percent 90 --target_bases 500000000 {input} > {output} 2>{log}"

rule assembly:
    input:
        "results/{sample}_filtered.fastq"
    output:
        "results/{sample}_genome.fa"
    conda:
        "t2tydna"
    log:
        "logs/{sample}_assembly.log"
    threads: 32
    shadow: "minimal"
    shell:
        """
        flye --nano-hq {input} --genome-size 12.5m --threads {threads} -i 2 --out-dir results/flye_tmp 2>{log}
        cp results/flye_tmp/assembly.fasta {output}
        """

#
# Nicolo's pipeline
#
rule mapping_all:
    input:
        reads = "results/{sample}_filtered.fastq",
        assembly = "results/{sample}_genome.fa"
    output:
        "results/{sample}_mapped.sam"
    conda:
        "t2tydna"
    log:
        "logs/{sample}_assembly.log"
    threads: 8
    shell:
        "minimap2 -ax map-ont -t {threads} {input.assembly} {input.reads} > {output} 2>{log}"

rule snv_counter:
    input:
        assembly = expand("results/{sample}_genome.fa", sample = samples),
        mapping = expand("results/{sample}_mapped.sam", sample = samples)
    output:
        "snv_table.csv"
    log:
        "logs/snv_count.log"
    
    

#
# Clothilde's pipeline
#

rule file_preparation_for_telomere_script:
    input:
        reads = "results/{sample}_filtered.fastq",
        assembly = "results/{sample}_genome.fa"
    output:
        "results/{sample}_data_position_table.tsv"
    conda:
        "telofinder"
    log:
        "logs/{sample}_file_preparation.log"
    script:
        "scr/file_preparation_telomere.py"
    
rule telomere_length:
    input:
        "results/{sample}_data_position_table.tsv"
    output:
        "results/{sample}_Filtred_Results.csv"
    conda:
        "telofinder"
    log:
        "logs/{sample}_telomere_length.log"
    threads:
        8
    shell:
        """
        mkdir results/{wildcards.sample}
        python scr/get_telomere_length.py --input_data {input} --output_dir results/{wildcards.sample}/ --threads {threads} --intern_min_length 100 --only_trim
        mv results/{wildcards.sample}/Filtred_Results.csv {output}
        """

rule plot_telomere_length:
    input:
        "results/{sample}_Filtred_Results.csv"
    output:
        "results/{sample}_tel_len.png"
    conda:
        "telofinder"
    log:
        "logs/{sample}_plotting_telomere_length.log"
    script:
        "scr/telomere_view_results.py"