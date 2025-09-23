#/bin/bash 

set -x

source ./config

cd $tmpdir

#conda activate mash

for i in $(ls $basedir/rep/*fa)
do
mash dist $inds".medaka.flye.final.fasta" $i >> $inds".mash" 2> /dev/null
done

#conda deactivate 

sort -k3,3 $inds".mash" > $inds".sort.mash"

rm $inds".mash"
