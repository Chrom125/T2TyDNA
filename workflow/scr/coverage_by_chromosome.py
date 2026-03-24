import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt

data = pd.read_csv(snakemake.input[0], sep = "\t", names = ["Chromosome", "Position", "Coverage"])

data_downsampled = data.iloc[::1000, :]

g = sns.relplot(
    data=data_downsampled,
    x='Position', y='Coverage',
    col='Chromosome', col_wrap=4,
    kind='line', height=3, aspect=1.5,
    facet_kws={'sharex': False}
)

g.set_axis_labels("Position (bp)", "Coverage Depth")
g.set_titles("Chromosome: {col_name}")

g.map(plt.axhline, y=data["Coverage"].mean(), color='red', linestyle='--', alpha=0.5)

# 5. Save and show
plt.tight_layout()
plt.ylim(0, 200)
plt.savefig(snakemake.output[0], dpi=300)