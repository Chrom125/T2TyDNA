#/bin/bash 

set -x

source ./config

cd $tmpdir

#conda activate mash

ref_pathfile=$(cat $inds".sort.mash" | cut -f2 | head -1)
gff_pathfile=$(echo $ref_pathfile | sed 's+.fa+.gff3+g')

#conda activate mummer
nucmer -t 10 -p $inds".end" $ref_pathfile $inds".genome.fa"
delta-filter -1 $inds".end.delta" >  $inds".end.delta_filter"
mummerplot --large --color --png $inds".end.delta_filter" -p $inds".end"
#conda deactivate
convert $inds".end.png" $inds".genome.pdf"

rm *rplot *gp *fplot *.delta *.png *.delta_filter 
