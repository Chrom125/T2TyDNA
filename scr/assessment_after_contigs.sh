#/bin/bash 

set -x

source ./config

cd $tmpdir

#conda activate mash

ref_pathfile=$(cat $inds".sort.mash" | cut -f2 | head -1)
gff_pathfile=$(echo $ref_pathfile | sed 's+.fa+.gff3+g')

#conda activate mummer
nucmer -t 10 -p $inds".flye.clean" $ref_pathfile $inds".flye.clean.fa"
delta-filter -1 $inds".flye.clean.delta" >  $inds".flye.clean.delta_filter"
mummerplot --large --color --png $inds".flye.clean.delta_filter" -p $inds".flye.clean"
#conda deactivate
convert $inds".flye.clean.png" $inds".flye.clean.pdf"

rm *rplot *gp *fplot *.delta *.png *.delta_filter 
