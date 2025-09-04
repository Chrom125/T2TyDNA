#!/bin/bash 

## Simplified Unified Nanopore de novo Saccharomyces Assembly Pipeline
## description: This script run the de novo assembly of the nano-hq reads generated for the SGRP5 project.
## date: 02/01/2025.
## Warning: the pipeline comes as it is. Many of the tools above have been installed in compartmentalized python and #conda environments; different scripts will attempt to activate and deactivate them. Details are provided along the script.
## This is the runner.
## This is the pipeline tree. 
#.
#├── rep # repo with additional necessary data
#├── scr # scripts
#├── asm # assembly
#├── seq # nanopore raw reads (Dorado basecalled)
#├── stat # step by step stats
#├── tmp # a tmp for temporary data
#└── ann # annotation 

set -x 

source ./config

/usr/bin/time -v bash "$basedir/scr/initialize"

/usr/bin/time -v bash "$basedir/scr/precontig" >  "$basedir/log/precontig.log" 2> "$basedir/log/precontig.err"

/usr/bin/time -v Rscript "$basedir/scr/nanoplot_plot.r" "$basedir" "$inds" > "$basedir/log/nanoplot_plot.log" 2> "$basedir/log/nanoplot_plot.err"

/usr/bin/time -v bash "$basedir/scr/contig" > "$basedir/log/contig.log" 2> "$basedir/log/contig.err"

/usr/bin/time -v bash "$basedir/scr/polishing" >  "$basedir/log/polishing.log" 2> "$basedir/log/polishing.err"

/usr/bin/time -v bash "$basedir/scr/mash.sh" >  "$basedir/log/mash.log" 2> "$basedir/log/mash.err"

/usr/bin/time -v bash "$basedir/scr/assign_cent.sh" >  "$basedir/log/assign_cent.log" 2> "$basedir/log/assign_cent.err"

/usr/bin/time -v Rscript "$basedir/scr/reorderscaffolds.r" "$asmdir" "$inds" "$tmpdir" > "$basedir/log/reordering.log" 2> "$basedir/log/reordering.err"

/usr/bin/time -v bash "$basedir/scr/assessment_after_contigs.sh" > "$basedir/log/assessment_after_contigs.log" 2> "$basedir/log/assessment_after_contings.err"

/usr/bin/time -v bash "$basedir/scr/revcomp.sh" > "$basedir/log/revcomp.log" 2> "$basedir/log/revcomp.err"

/usr/bin/time -v Rscript "$basedir/scr/reorderchrs.r" "$tmpdir" "$inds" > "$basedir/log/reorderchrs.log" 2> "$basedir/log/reorderchrs.err"

/usr/bin/time -v bash "$basedir/scr/assessment_reorderedchrs.sh" > "$basedir/log/assessment_reorderedchrs.log" 2> "$basedir/log/assessment_reorderedchrs.err"

/usr/bin/time -v bash "$basedir/scr/backmapping" >  "$basedir/log/backmapping.log" 2> "$basedir/log/backmapping.err"

## phasing should be turned on with intermediate levels of het. or anytime it is relevant
if [[ $phasing == "yes" ]]
then
/usr/bin/time -v bash "$basedir/scr/phasing" > "$basedir/log/phasing.log" 2> "$basedir/log/phasing.err"
fi

/usr/bin/time -v bash "$basedir/scr/telomer_dist" >  "$basedir/log/telomer_dist.log" 2> "$basedir/log/telomer_dist.err"

/usr/bin/time -v Rscript "$basedir/scr/telomer_dist_plot.r" "$telodir" "$inds" > "$basedir/log/telomer_dist_plot.log" 2> "$basedir/log/telomer_dist_plot.err"

/usr/bin/time -v bash "$basedir/scr/annotation" >  "$basedir/log/annotation.log" 2> "$basedir/log/annotation.err"

/usr/bin/time -v Rscript "$basedir/scr/cleangff.r" "$tmpdir" "$inds" > "$basedir/log/cleangff.log" 2> "$basedir/log/cleangff.err"

/usr/bin/time -v bash "$basedir/scr/organizeres.sh" >  "$basedir/log/organizeres.log" 2> "$basedir/log/organizeres.err"
