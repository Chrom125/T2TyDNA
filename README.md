<p align="center">
  <img src="https://github.com/nicolo-tellini/T2TyDNA/blob/main/logot2tydna.png" alt="logo pipe" width="30%"/>
</p>

> ⚠️⚠️⚠️ THIS DIRECTORY IS UNDER CONSTRUCTION AND THE PIPELINE UNDER IMPROVEMENT AND OPTIMIZATION 

[![Licence](https://img.shields.io/github/license/nicolo-tellini/sunp?style=plastic)](https://github.com/nicolo-tellini/T2TyDNA/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/nicolo-tellini/sunp?style=plastic)](https://github.com/nicolo-tellini/T2TyDNA/releases)
[![commit](https://img.shields.io/github/last-commit/nicolo-tellini/sunp?color=yellow&style=plastic)](https://github.com/nicolo-tellini/T2TyDNA/graphs/commit-activity)

## Description
This pipeline is optimized for genome assembly of **Saccharomyces** using Oxford Nanopore R10.4 reads.

> ⚠️ **Note**: For larger or more complex genomes, additional sequencing technologies (e.g., PacBio HiFi, Hi-C, ONT ultralong) are recommended. This pipeline is not suited for such cases.

### Purpose
This repository is intended for de novo assembly of Saccharomyces strains for which (by default) R10.4 ONT are available.
Older chemistries require installing the appropriate version of medaka (see Dependencies below), increasing the round of polishing up to 3 and, change flye settings in ```scr/config```.

> ⚠️ **Note**: This pipeline is provided as-is. It will **not** be adapted for individual cases.

---

## Installation

Install conda
Create a new environnement and install snakemake :
conda create -c conda-forge -c bioconda -c nodefaults -n snakemake snakemake

Then find a place and clone the repository :
git clone https://github.com/Chrom125/T2TyDNA/tree/snakemake

## Usage

Put your .fastq.gz files in a folder inside the data folder.
Edit the config file to add your new sample to the pipeline.
Edit the config file to add the reference for the scaffolding.

Launch in the main folder :
snakemake --cores {threads} --use-conda

Results are in the results folder

# Citation

Please, if you use this pipeline or reuse part of it cite this repo, along with all the tools included. 

# TODO list

### Additional
