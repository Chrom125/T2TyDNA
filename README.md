[![Licence](https://img.shields.io/github/license/nicolo-tellini/sunp?style=plastic)](https://github.com/nicolo-tellini/T2TyDNA/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/nicolo-tellini/sunp?style=plastic)](https://github.com/nicolo-tellini/T2TyDNA/releases)
[![commit](https://img.shields.io/github/last-commit/nicolo-tellini/sunp?color=yellow&style=plastic)](https://github.com/nicolo-tellini/T2TyDNA/graphs/commit-activity)

## Description
This pipeline is optimized for estimating the telomere length distribution of *Saccharomyces* strains evolved in the lab using Oxford Nanopore R10.4 reads.

> ⚠️ **Note**: This pipeline is provided as-is.

---

## Issues & Support

If you encounter problems, please open an issue and include the full contents of the logs directory.

---

## Dependencies

### Installation (recommended)

The pipeline relies on a set of established bioinformatics tools. 
The installation environment is named **donatelo**. 

```sh
mamba create -n t2tydna -c conda-forge -c bioconda python=3.10 -y 
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
    ragtag=2.1.0 \
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
> ⚠️ IMPORTANT: TeloFinder need to be installed separately on a dirrente env following the instructions:

```
mamba create -n telofinder python=3.10

mamba activate telofinder

git clone https://github.com/GillesFischerSorbonne/telofinder.git

cd telofinder
```
> Before running ```pip install .``` follow the correction here listed at [issue13](https://github.com/GillesFischerSorbonne/telofinder/issues/13#issuecomment-2124729333)
> From the parental telofinder dir run:
```
pip install .
```

> Telofinder accumulates pybedtools files on the temp dir consider removing that files at the end of each run.

## Download

## Download
 
:octocat: :
  
```sh
git clone --branch donatelo https://github.com/nicolo-tellini/T2TyDNA.git
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

Add a ref genome and the annotation according to the instruction in ```./rep/README```. 

```CBS432.genome.fa``` and ```CBS432.genome.gff3``` are an example while blablabla **must** be kept.

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
inds=samplename # Sample name
post_filtering_coverage=40 # target covegare for filtlong
model="r1041_e82_400bps_sup_v4.3.0" # dorado model basecalling
ont_type="--nano-hq"
rounds=2 # rounds of long-read based polishing
genome_size="12.5m"

```
Be sure ```t2tydna``` env is active. 

Run ```runner.sh``` :runner: 

```{bash}
bash runner.sh > runner.log 2> runner.err &
```
Main results are in :

out:

- plot (.pdf), genome (.fa) and annotation (.gff3)

# Citation

Please, if you use this pipeline or reuse part of it cite this repo, along with all the tools included. 

# TODO list
