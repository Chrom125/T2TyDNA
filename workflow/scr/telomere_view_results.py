import pandas as pd
import matplotlib.pyplot as plt

# For matplotlib, for box plot, a list is the simplest to code.
data_list = []

for sn_input in snakemake.input:
    results = pd.read_csv(sn_input, sep="\t")
    data_list.append(results["len"].to_list())


print(data_list)

plt.boxplot(data_list)
plt.title("SNP Count Distribution per sample")
plt.ylabel("Number of SNPs")
plt.savefig(snakemake.output[0])
#plt.savefig(results[0] + "_output.png")
plt.clf()
