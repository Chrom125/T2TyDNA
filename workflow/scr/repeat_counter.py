import pandas as pd

sample_list = []
yrf11_list = []
yrf15_list = []

for gff_file in snakemake.input:
    data = pd.read_csv(gff_file, sep = "\t", skiprows=2, header = None)
    data.columns = ["chromosome", "source", "type", "start", "end", "score", "strand", "phase", "attributes"]
    data["id"] = data["attributes"].str.split(";").str[0]
    data["motif"] = data["attributes"].str.split(" ").str[1].str[1:-1].str.split(":").str[-1]
    data["motif_start"] = data["attributes"].str.split(" ").str[2]
    data["motif_end"] = data["attributes"].str.split(" ").str[3]

    sample_list.append(gff_file.split("/")[-1])
    yrf11_list.append(data.loc[data["motif"] == "YRF1-1"].shape[0])
    yrf15_list.append(data.loc[data["motif"] == "YRF1-5"].shape[0])

dataframe_dict = {
    "Sample": sample_list,
    "YRF1-1 number": yrf11_list, 
    "YRF1-5 number": yrf15_list
}

data = pd.DataFrame(dataframe_dict)
data.to_csv(snakemake.output[0])
