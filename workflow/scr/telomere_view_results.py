import pandas as pd
import matplotlib.pyplot as plt

# For matplotlib, for box plot, a list is the simplest to code.
data_list = []
labels = []

for sn_input in snakemake.input:
    label = sn_input.split("/")[1]
    results = pd.read_csv(sn_input, sep="\t")
    data_list.append(results["len"].to_list())
    labels.append(label)

print(data_list)
plt.figure(figsize=(16, 8))
plt.boxplot(data_list, labels=labels, showfliers=False)
plt.title("Length of telomeres by sample")
plt.ylabel("Base pairs (bp)")
plt.savefig(snakemake.output[0])
#plt.savefig(results[0] + "_output.png")
plt.clf()
