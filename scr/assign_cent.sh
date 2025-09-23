#!/bin/bash

set -x

source ./config

cd $tmpdir

ref_pathfile=$(cat $inds".sort.mash" | cut -f2 | head -1)
gff_pathfile=$(echo $ref_pathfile | sed 's+.fa+.gff3+g')

cd $repdir

grep CEN $gff_pathfile > cen.coord

touch cen.fasta
rm cen.fasta

while read -r line 
do 
cont=$(echo $line | cut -d" " -f1)
start=$(echo $line | cut -d" " -f4)
end=$(echo $line | cut -d" " -f5)

samtools faidx $ref_pathfile $cont:$start-$end >> cen.fasta

done < cen.coord

fasta36 -d1 -b1 -m8 cen.fasta $tmpdir/$inds".medaka.flye.final.fasta" > $tmpdir/$inds."cen-pos.flye.txt"

rm cen.coord cen.fasta
