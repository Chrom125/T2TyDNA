import json

rule mummerplot:
    """
    This rule is to check the quality of the assembly.
    Basically, the rule plot the assembly against a reference genome. If everything is going well, we have a beautiful straight line
    of the form y = x in bright red.
    """
    input:
        assembly = "results/{sample}/{sample}_genome_ordered.fa",
        reference = "results/{sample}/reference_sample.fa"
    output:
        report("results/{sample}/nucmer_results/nucmer_mqc.png", category = "{sample}")
    conda:
        "../envs/mummer.yaml"
    log:
        "results/{sample}/logs/{sample}_mummerplot/log"
    shell:
        """
        nucmer -p results/{wildcards.sample}/nucmer_results/nucmer {input.reference} {input.assembly}
        delta-filter -1 results/{wildcards.sample}/nucmer_results/nucmer.delta > results/{wildcards.sample}/nucmer_results/nucmer.delta_filter
        mummerplot --large --color --png results/{wildcards.sample}/nucmer_results/nucmer.delta_filter -p results/{wildcards.sample}/nucmer_results/nucmer_mqc
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
        "results/{sample}/busco_results/short_summary.specific.saccharomycetaceae_odb12.busco_results.json"
    conda:
        "../envs/busco.yaml"
    log:
        "results/{sample}/logs/{sample}_busco.log"
    threads:
        16
    shell:
        """
        busco -f -i {input.assembly} -m genome -l saccharomycetaceae_odb12 -c {threads} -o results/{wildcards.sample}/busco_results
        """

# rule parse_json_busco:
#     """
#     Parsing the BUSCO code to get all the data into a csv files for the report.
#     """
#     input:
#         json = "results/{sample}/busco_results/short_summary.specific.saccharomycetaceae_odb12.busco_results.json"
#     output:
#         tsv = report("results/{sample}/busco_results.tsv", category = "{sample}")
#     run:
#         with open(input.json, 'r') as f:
#             data = json.load(f)
        
#         s = data["results"]
#         line = {
#             "Sample": wildcards.sample,
#             "Complete": s["Complete percentage"],
#             "Single": s["Single copy percentage"],
#             "Multi copy percentage": s["Multi copy percentage"],
#             "Fragmented": s["Fragmented percentage"],
#             "Missing": s["Missing percentage"],
#             "Total": data["lineage_dataset"]["number_of_buscos"]
#         }

#         with open(output.tsv, 'w') as f:
#             f.write("\t".join(line.keys()) + "\n")
#             f.write("\t".join(str(x) for x in line.values()) + "\n")

rule quast:
    """
    Quast is a tool to check the quality of the assembly.
    It gives you statistics like N50 (You take the sum from the largest reads to the shortest and you add them until you reach half of the assembly.
    When you reach half, you take the length of the last reads taken.), L50 but also number of mismatch and everything.
    For now, I have like 20 mismatches usually. I don't know if it's normal.
    """
    input:
        assembly = "results/{sample}/{sample}_genome_ordered.fa",
        reference = "results/{sample}/reference_sample.fa"
    output:
        "results/{sample}/quast_results/report.pdf"
    conda:
        "../envs/quast.yaml"
    log:
        "results/{sample}/logs/{sample}_quast_report.log"
    shell:
        "quast {input.assembly} -r {input.reference} -o results/{wildcards.sample}/quast_results"
