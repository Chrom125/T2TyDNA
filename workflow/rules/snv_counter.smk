rule mapping_all:
    input:
        reads = "results/{sample}/{sample}_filtered.fastq",
        assembly = "results/{sample}/{sample}_genome_ordered.fa"
    output:
        "results/{sample}/{sample}_mapped.bam"
    conda:
        "t2tydna"
    log:
        "results/{sample}/logs/{sample}_assembly.log"
    threads: 8
    shell:
        """
        minimap2 -ax map-ont -t {threads} {input.assembly} {input.reads} | samtools sort -o {output}
        """

rule clair3:
    input:
        mapping = "results/{sample}/{sample}_mapped.bam"
        reference = "results/{sample}/{sample}_genome_ordered.fa"
    output:
        "results/{sample}/clair3_output/merge_output.vcf.gz"
    threads: 32
    shell:
        """
        MODEL_NAME="r1041_e82_400bps_sup_v500"
        run_clair3.sh --bam={input.mapping} --ref_fn={input.reference} --threads={threads} --platform="ont" --output="results/{sample}/clair3_output/" --model_path="${CONDA_PREFIX}/bin/models/${MODEL_NAME}" --include_all_ctgs
        """

rule snv_counter:
    """
    Reads from the .vcf.gz files made by clair3 to summarize the number of SNP and indels found in the files.
    """
    input:
        assembly = expand("results/{sample}/{sample}_genome.fa", sample = samples),
        mapping = expand("results/{sample}/{sample}_mapped.sam", sample = samples)
    output:
        "{sample}_snv_table.csv"
    log:
        "results/{sample}/logs/{sample}_snv_count.log"
    script:
        "../scr/snv_counter.py"
