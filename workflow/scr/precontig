#!/bin/bash 

## filtering and read selection (ONT 60X)

set -x

source ./config

genome_size="12500000"

target_bases=$((genome_size * post_filtering_coverage))

##conda activate filtlong
#conda activate chopper
## best reads
#filtlong --min_length 10000 --mean_q_weight 10 --window_q_weight 5 --target_bases $target_bases $seqdir/$inds.fastq.gz | pigz > $seqdir/$inds.filtlong.fastq.gz
zcat $seqdir/$inds.fastq.gz | chopper -q 15 -l 10000 | pigz > $seqdir/$inds.chop.fastq.gz 
#conda deactivate

#conda activate filtlong
## best reads
filtlong --target_bases $target_bases $seqdir/$inds.chop.fastq.gz | pigz > $seqdir/$inds.filtlong.fastq.gz
#conda deactivate

rm  $seqdir/$inds.chop.fastq.gz 

#conda activate nanoplot
## nanoplot stats
NanoPlot --fastq $seqdir/$inds.filtlong.fastq.gz --outdir $seqdir/nanoplot_$inds --raw --no_static --tsv_stats --info_in_report
rm $seqdir/nanoplot_$inds/*html

#conda deactivate
