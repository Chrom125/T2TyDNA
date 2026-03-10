rule file_preparation_for_telomere_script:
    """
    The telomere length uses a script made by : C. Garrido : https://github.com/Telomere-Genome-Stability/Yeast2025
    This script asks for a tsv table with the path of the different reads.
    This is what the script is making. It's just taking the path of the different files.
    """
    input:
        reads = "results/{sample}/{sample}_filtered.fastq",
        assembly = "results/{sample}/{sample}_genome_ordered.fa"
    output:
        "results/{sample}/{sample}_data_position_table.tsv"
    conda:
        "telofinder"
    log:
        "results/{sample}/logs/{sample}_file_preparation.log"
    script:
        "../scr/file_preparation_telomere.py"
    
rule telomere_length:
    """
    Script to get the telomere length of the reads by C. Garrido.
    It uses telofinder from G. Fischer.
    It gets the length of telomeres from individual reads so that we can make a histogram.
    """
    input:
        table = "results/{sample}/{sample}_data_position_table.tsv",
        reads = "results/{sample}/{sample}_filtered.fastq"
    output:
        "results/{sample}/{sample}_Filtred_Results.csv"
    conda:
        "telofinder"
    log:
        "results/{sample}/logs/{sample}_telomere_length.log"
    threads:
        8
    shell:
        """
        python workflow/scr/get_telomere_length.py --input_data {input.table} --output_dir results/{wildcards.sample}/ --threads {threads} --intern_min_length 100 --only_trim
        mv results/{wildcards.sample}/Filtred_Results.csv {output}
        """

rule plot_telomere_length:
    """
    We get the data from the telomere length rule but we make the plot in this one.
    Here we make a nice boxplot.
    """
    input:
        expand("results/{sample}/{sample}_Filtred_Results.csv", sample = samples)
    output:
        "results/common/tel_len.png"
    conda:
        "telofinder"
    log:
        "results/common/logs/plotting_telomere_length.log"
    script:
        "../scr/telomere_view_results.py"
