rule mapping_all:
    input:
        reads = "results/{sample}/{sample}_filtered.fastq",
        assembly = "results/{sample}/{sample}_genome_ordered.fa",
    output:
        bam = "results/{sample}/{sample}_mapped.bam",
        bai = "results/{sample}/{sample}_mapped.bam.bai",
        faidx = temp("results/{sample}/{sample}_genome_ordered.fa.fai")
    conda:
        "t2tydna"
    log:
        "results/{sample}/logs/{sample}_assembly.log"
    threads: 8
    shell:
        """
        minimap2 -ax map-ont -t {threads} {input.assembly} {input.reads} | samtools sort -o {output.bam}
        samtools index {output.bam}
        samtools faidx {input.assembly}
        """

rule clair3:
    input:
        mapping = "results/{sample}/{sample}_mapped.bam",
        mapping_indexed = "results/{sample}/{sample}_mapped.bam.bai",
        reference = "results/{sample}/{sample}_genome_ordered.fa",
        faidx = "results/{sample}/{sample}_genome_ordered.fa.fai"
    output:
        "results/{sample}/clair3_output/merge_output.vcf.gz"
    threads: 8
    log:
        "results/{sample}/logs/{sample}_clair3.log"
    params:
        MODEL_NAME = "r1041_e82_400bps_sup_v500"
    conda:
        "clair3_v2"
    shell:
        """
        MODEL_NAME="r1041_e82_400bps_sup_v500"
        /home/lsenez/analyse/Clair3/run_clair3.sh \
        --bam_fn={input.mapping} \
        --ref_fn={input.reference} \
        --threads={threads} \
        --platform="ont" \
        --model_path="/home/lsenez/analyse/Clair3/models/r1041_e82_400bps_sup_v500" \
        --output=results/{wildcards.sample}/clair3_output/ \
        --include_all_ctgs 2>{log}
          """

rule snv_counter:
    input:
        "results/{sample}/clair3_output/merge_output.vcf.gz"
    output:
        "results/{sample}/summary_variant_counter.csv"
    shell:
        """
        bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\n' {input} | sort -V -k1,1 -k2,2n > {output}
        """
