#!/bin/bash

set -x

source ./config

cd $tmpdir

ref_pathfile=$(cat $inds".sort.mash" | cut -f2 | head -1)
gff_pathfile=$(echo $ref_pathfile | sed 's+.fa+.gff3+g')

nucmer -t 10 -p $inds".revseq" $ref_pathfile $inds".flye.clean.fa"
delta-filter -1 $inds".revseq.delta" >  $inds".revseq.delta_filter"

show-coords -rclT $inds".revseq.delta_filter"  | tail -n +4 | awk '$6 >= 50000' | awk '$3 >= $4' | sed 's+chr++g' | awk '$12 == $13' | cut -f12 | sort -u > revertcomplement_chrs_list.txt

seqkit grep -f revertcomplement_chrs_list.txt $inds".flye.clean.fa" > tobereverted.fa

revseq -notag tobereverted.fa reverted.fa

seqkit grep -v -f revertcomplement_chrs_list.txt $inds".flye.clean.fa" > tobemergedwithreverted.fa

cat tobemergedwithreverted.fa reverted.fa > goodorderchrs.fa

rm $inds".revseq.delta" $inds".revseq.delta_filter" revertcomplement_chrs_list.txt tobereverted.fa reverted.fa tobemergedwithreverted.fa 
