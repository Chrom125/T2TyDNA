import pandas as pd

table_dict = []

table_dict.append({
    "Strain": snakemake.wildcards.sample,
    "Reference": snakemake.input.assembly,
    "Trim_reads": snakemake.input.reads
    })

df = pd.DataFrame(table_dict)

df.to_csv(snakemake.output[0], sep="\t")
