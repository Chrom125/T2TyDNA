<p align="center">
  <img src="https://github.com/nicolo-tellini/T2TyDNA/blob/main/logot2tydna.png" alt="logo pipe" width="30%"/>
</p>

> ⚠️⚠️⚠️ THIS DIRECTORY IS UNDER CONSTRUCTION

[![Licence](https://img.shields.io/github/license/nicolo-tellini/sunp?style=plastic)](https://github.com/nicolo-tellini/T2TyDNA/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/nicolo-tellini/sunp?style=plastic)](https://github.com/nicolo-tellini/T2TyDNA/releases)
[![commit](https://img.shields.io/github/last-commit/nicolo-tellini/sunp?color=yellow&style=plastic)](https://github.com/nicolo-tellini/T2TyDNA/graphs/commit-activity)

## Description
This pipeline is optimized for genome assembly of **Saccharomyces** using Oxford Nanopore R10.4 reads. If your data comes from older Nanopore chemistries, the workflow will require adjustments that are not provided by default; see the section blablabla to adjust the pipeline according to your chemistry. The pipeline can also be applied to other yeast species; the scripts need to be adjusted to meet the features of the organism. See the section below to discover possible applications **beyond Saccharomyces**.

> ⚠️ **Note**: For larger or more complex genomes, additional sequencing technologies (e.g., PacBio HiFi, Hi-C, ONT ultralong) are recommended. This pipeline is not suited for such cases.

### Purpose
This repository is intended for de novo assembly of Saccharomyces strains for which R10.4 ONT are available.

> ⚠️ **Note**: This pipeline is provided as-is. It will **not** be adapted for individual cases.

---
<details>
<summary> Old workflow </summary>
## Workflow
The pipeline consists of multiple sequential modules to generate a T2T genome assembly, polishing, quality control, telomere length estimation, ORFs identification and functional annotation. 
Below is an overview of each step:

### 1. Initialization & Pre-processing

- **`initiate`**: Sets up the directory structure and required files.
- **`precontig`**: Filters long reads before assembly, based on user-defined thresholds  
  *(default: minimum read length = 10 kb,  average read quality 15, target coverage = 50×)*.

  <details>
  <summary> Q len plot </summary>
    <p align="center">
      <img src="https://github.com/nicolo-tellini/T2TyDNA/blob/main/qlenplot.png" alt="logo pipe" width="50%"/>
    </p>
  </details>

### 2. Assembly

- **`contig`**: Performs de novo assembly using **Flye**.
- **`QUAST`** and **`BUSCO`**: Evaluate assembly quality and gene completeness.
- - **`mash`** and **`MUMmer`**

### 3. Intermediate Assessment

- **`assessment_after_contigs`** (**`mash`** and **`MUMmer`**): Aligns the draft assembly to a reference genome using **MUMmer**  
  *(reference genomes aree placed in the `rep/` directory and automatically selected)*.

### 4. Polishing

A three-step polishing process:

- **`minimap2` + `racon`**: One round of correction with ONT reads.
- **`medaka`**: Generates high-quality consensus (one round).
- **`assign_cent`**: Extracts centromere positions from the reference annotation and maps them to the new assembly.
-  **`reorderscaffolds`**: Names and orders contigs based on centromere positions.

> If multiple centromeres are found on the same contig (e.g., `IV_XIII`), this likely indicates an assembly artefact requiring manual inspection.

### 5. Telomere Length Estimation

- **`backmapping`**: Filtered ONT reads are mapped back to the de novo assembled genome.
- **`samtools`**: Extraction of reads mapping at the beginning and end of the chromosome (those covering a range of 20kb)
- **`telofinder`**: Detects telomeric repeats from the reads (Only terminal signals are maintained).

<details>
  <summary> TEL len plot </summary>
  <p align="center">
    <img src="https://github.com/nicolo-tellini/T2TyDNA/blob/main/tel_dist.png" alt="logo pipe" width="30%"/>
  </p>
</details>

### 6. Backmapping & Annotation

- **`backmapping`**: Maps filtered ONT reads back to the polished assembly. Useful to identify structural anomalies or coverage issues.
- **`annotation`**: Fast functional annotation with **eggNOG-mapper** for gene content overview.
  
  > ⚠️ **Note**: This is not intended to be a comprehensive genome annotation.

---

## Artefact Detection

Mummer plots help detect artefacts. Manual curation is necessary if the alignment shows the following patterns:

1. Telomers embedded in central chrs positions
  <details>
  <summary> Artefact from MUMmer </summary>
    <p align="center">
      <img src="https://github.com/nicolo-tellini/T2TyDNA/blob/main/artefact.png" alt="Artifact ONT" width="70%"/>
    </p>
</details>

2. Local accumulation of unexpected SNPs  
3. Abrupt coverage drops  
4. Extensive soft/hard read clipping

  <details>
  <summary> Artefact from mapping </summary>
    <p align="center">
      <img src="https://github.com/nicolo-tellini/sunp/blob/main/artifact_eaxample.png" alt="Artifact ONT"/>
    </p>
</details>

[TiGmint](https://github.com/bcgsc/tigmint) can support manual postprocessing, but it is not implemented in the pipeline as its use is case-specific. 

</details>

---

## Issues & Support

If you encounter problems, please open an issue and include the full contents of the logs directory.

NO support is given for Windows OS, please read [here](https://towardsdatascience.com/why-do-bioinformaticians-avoid-using-windows-c5acb034f63c/).

---

## Dependencies

### Installation (recommended)

The pipeline relies on a set of established bioinformatics tools. 
The installation environment is named **t2tydna**. 

```sh
mamba create -n t2tydna python=3.10 -y
mamba activate t2tydna
```

The tools below can be installed as follows:

```sh
mamba install -y -c conda-forge -c bioconda \
    filtlong=0.2.1 \
    pytorch=2.3 \
    numpy \
    h5py \
    mappy \
    nanoplot=1.46.0 \
    augustus=3.5.0 \
    gffread=0.12.7 \
    eggnog-mapper=2.1.13 \
    flye=2.9.6 \
    seqkit=2.10.* \
    quast=5.3.0 \
    busco=5.8.2 \
    minimap2=2.29 \
    racon=1.5.0 \
    medaka=2.0.1 \
    chopper=0.10.0 \
    bwa=0.7.19 \
    samtools=1.21 \
    repeatmasker=4.2.1 \
    mummer4=4.0.1 \
    pybedtools \
    emboss=6.6.0 \
    seqkit=2.10.1 \
    mash=2.3 \
    r-base=4.3 \
    r-essentials \
    r-seqinr \
    r-R.utils \
    r-data.table \
    r-ggplot2 \
    r-viridis \
    r-ggextra \
    r-ggpubr \
    pip \
    2>&1 | tee conda_install.log
```
> IMPORTANT: If your not instered in telomere length estimates skip this step.

> ⚠️ TeloFinder need to be installed separately following the instructions at [Telofinder Documentation](https://telofinder.readthedocs.io/en/latest/#installation).

> IMPORTANT: before running ```pip install .``` follow the correction here listed at [issue13](https://github.com/GillesFischerSorbonne/telofinder/issues/13#issuecomment-2124729333)

> IMPORTANT: by default telomere length estimates are disabled, you can activate it by changing the value of tel_len from "no" to "yes" in the ```./scr/config``` file.  

### Annotation Step

The annotation process uses **eggNOG-mapper**, which requires a **local database** not included in the repository.  
To set it up manually:

```bash
mkdir $HOME/eggnog_db

download_eggnog_data.py --data_dir $HOME/eggnog_db
```
The pipeline expects to find the eggNOG database in:
```bash
$HOME/eggnog_db
```
If your database is located elsewhere, update the relevant variable in the config file accordingly.

## Download
 
:octocat: :
  
```sh
git clone --recursive https://github.com/nicolo-tellini/T2TyDNA.git
```

## Content

:open_file_folder: :

```{bash}
.
├── rep
│    └── README
├── scr
└── seq

3 directories 
```

- ```rep``` : repository with ref. assembly and annotations (see ScRapDB),</br>
- ```scr``` : scripts,</br>
- ```seq``` : put the FASTQs files here,</br>

### About the fastqs 

FASTQs data **must** be gziped and suffixed as samplename **.fastq.gz** (ont).
FASTQs are located inside seq dir. 

### About the rep dir 

Add a ref genome and the annotation according to the instruction in ```./rep/README```

### How to run

Edit USER VARIABLE in the ```./scr/config``` :page_with_curl: 

```{bash}
###########################################################
#                   CONFIGURATION FILE                    #
#                                                         #
# This configuration file sets parameters for sample      #
# processing and analysis. Modify these values according  #
# to your project's requirements.                         #
#                                                         #
#                                			              #
# Contact me at nicolo.tellini.2@gmail.com		          #
###########################################################

##########################################################
#		     USER VARIABLE			                     #
##########################################################
 
nt=16 # Number of threads
inds=yS199 # Sample name
post_filtering_coverage=30 # target covegare for filtlong
model="r1041_e82_400bps_sup_v4.3.0" # dorado model basecalling

short_reads="no" # activate it if appropriate. This is not used for polishing but for monitoring artefacts.  
phasing="no" # activate it if appropriate
tel_len="no" # activate it if appropriate
eggdb=$HOME/eggnog_db # change only if you placed eggnog_db in a different location

```

Run ```runner.sh``` :runner: 

```{bash}
bash runner.sh &
```
Main results are in :

out:

```{bash}
.
├── '.genome.fa' # final assembly
├── '.genome.pdf' # mummerplot against ref genome
└── '.genome.ann' # annotation

3 files, 

```
If you are interested in tel length estimates:

tlo : 
- telofinder results plots (.pdf) and summary table (.summary.txt)

# Citation

Please, if you use this pipeline or reuse part of it cite this repo, along with all the tools included. 

# TODO list

### Additional
