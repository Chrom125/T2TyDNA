import pandas as pd
import matplotlib.pyplot as plt

print("Plotting for : " + snakemake.wildcards.sample)

results = pd.read_csv(snakemake.input[0], sep="\t")

print(results["len"].mean())

plt.hist(results["len"], bins=20)
plt.xlabel("Longueur des télomères (en bp)")
plt.ylabel("Effectif des reads ayant la longueur x")
plt.title("Histogramme du nombre de reads en fonction de leur longueur")
plt.savefig(snakemake.output[0])
#plt.savefig(results[0] + "_output.png")
plt.clf()
