import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import sys

gff_cols = ['seqid', 'source', 'type', 'start', 'end', 'score', 'strand', 'phase', 'attributes']
gff_main = pd.read_csv(snakemake.input[1],
                    sep='\t', 
                    comment='#', 
                    names=gff_cols)
gff_removal = pd.read_csv(snakemake.input[2], sep = "\t", comment="#", names=gff_cols)

gff_removal = gff_removal[["seqid", "start", "end"]]


cols = ["chrom", "pos", "ref", "alt", "qual", "format", "sample"]


variant_calling = pd.read_csv(snakemake.input[0], sep = "\t", names = cols, index_col = False)
variant_calling["presence_percentage"] = variant_calling["sample"].str.split(":").str[-1]
variant_calling.drop(["format", "sample"], inplace = True, axis = 1)

# Remove variant that aren't in coding regions
variant_calling = pd.merge(variant_calling, gff_main, left_on='chrom', right_on='seqid')
variant_calling = variant_calling.query('pos >= start and pos <= end')
variant_calling = variant_calling[["chrom", "pos", "ref", "alt", "qual", "presence_percentage"]]

# Remove duplicates created by the merge with gff
variant_calling.drop_duplicates(inplace=True)

# Remove variant that are on problematic annotations like telomere or Ty repeats
temp_copy = variant_calling.copy()
for index, row in variant_calling.iterrows():
    relevant_df = gff_removal.loc[gff_removal["seqid"] == row["chrom"]]
    for index_removal, removal_row in relevant_df.iterrows():
        if row["pos"] >= removal_row["start"] and row["pos"] <= removal_row["end"]:
            temp_copy.drop(temp_copy[(temp_copy["chrom"] == row["chrom"]) & (temp_copy["pos"] == row["pos"])].index, inplace=True)
variant_calling = temp_copy

variant_calling.to_csv(snakemake.output[0], sep="\t")
