from Bio import SeqIO

record_dict = SeqIO.to_dict(SeqIO.parse(snakemake.input[0], "fasta"))

order = [
    "chrI_RagTag",
    "chrII_RagTag",
    "chrIII_RagTag",
    "chrIV_RagTag",
    "chrV_RagTag",
    "chrVI_RagTag",
    "chrVII_RagTag",
    "chrVIII_RagTag",
    "chrIX_RagTag",
    "chrX_RagTag",
    "chrXI_RagTag",
    "chrXII_RagTag",
    "chrXIII_RagTag",
    "chrXIV_RagTag",
    "chrXV_RagTag",
    "chrXVI_RagTag",
#    "chrMT_RagTag"
]

ordered_records = [record_dict[name] for name in order if name in record_dict]

for i in range(len(ordered_records)):
    ordered_records[i].id = ordered_records[i].id.split("_")[0]
    ordered_records[i].name = ordered_records[i].name.split("_")[0]
    ordered_records[i].description = ordered_records[i].description.split("_")[0]

SeqIO.write(ordered_records, snakemake.output[0], "fasta")