#!/bin/bash

set -x

source ./config

cd $repdir

fasta36 -d1 -b1 -m8 YLR163C.CBS432.fa $tmpdir/$inds".genome.fa" > $tmpdir"/ylr163c.fasta36.txt"
