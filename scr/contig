#!/bin/bash

set -x

source ./config

ont_type=$1 
genome_size=$2

#conda activate flye
# assembly 
flye $ont_type $seqdir/$inds.filtlong.fastq.gz --genome-size $genome_size --threads 32 -i 2 --out-dir $asmdir/flye
#conda deactivate

#conda activate seqkit
# discard contings shorter then 10 kb
seqkit seq -g -m 10000 $asmdir/flye/assembly.fasta > $asmdir/flye/assembly.l.fasta
#conda deactivate

#conda activate quast
# QUAL and completeness assessment
quast.py $asmdir/flye/assembly.l.fasta -o $asmdir/quast_flye
#conda deactivate

cd $asmdir

#conda activate busco
# completeness assessment 
busco -i $asmdir/flye/assembly.l.fasta -l saccharomycetes_odb10 -o busco_flye -m genome -f
#conda deactivate

cd $basedir/scr

cp -r $asmdir/flye/assembly.l.fasta $basedir/tmp/$inds.flye.raw.fasta
