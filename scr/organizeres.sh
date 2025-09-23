#!/bin/bash

set -x

source ./config

ln -s $tmpdir/$inds".genome.fa" $outdir/$inds".genome.fa"

ln -s $tmpdir/$inds".genome.pdf" $outdir/$inds".genome.pdf"

ln -s $tmpdir/$inds".cdsclean.gff3" $outdir/$inds".gff3"
