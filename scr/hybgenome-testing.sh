# good luck !
nanoreads=SRR18661818.fastq.gz  # importante name.fastq.gz
parent1=S288C.asm01.HP0.nuclear_genome.tidy.fa # importante name.blablabla
parent2=CBS7001.asm01.HP0.nuclear_genome.tidy.fa

str=$(echo $nanoreads | cut -d"." -f1)

filtlong --min_length 1000 --min_mean_q 20 $nanoreads | pigz > $str.filt.fastq.gz

flye --nano-hq $str.filt.fastq.gz --genome-size 24m --threads 44 --out-dir flye_out

cp -r flye_out/assembly.fasta .

busco -i assembly.folded.fasta -l saccharomycetes_odb10 -m genome -c 8 --out_path busco -o assembly.bp.hap1.p_ctg.busco

p1=$(echo $parent1 | cut -d"." -f1)
p2=$(echo $parent2 | cut -d"." -f1)

sed "s/^>/>${p1}_/" $parent1 > parent1.renamed.fa
sed "s/^>/>${p2}_/" $parent2 > parent2.renamed.fa 

cat  parent1.renamed.fa parent2.renamed.fa > parent1-parent2.renamed.fa

## controllare coverage per aneuploidie e alterazione strane e stima numero cromosomi  
minimap2 -t 16 -x map-ont -a --secondary=no parent1-parent2.renamed.fa $nanoreads \
  | samtools sort -@ 16 -m 4G -o ont.vs.ref.bam
samtools index ont.vs.ref.bam

samtools faidx parent1-parent2.renamed.fa

bedtools makewindows -g parent1-parent2.renamed.fa.fai -w 5000 | bedtools coverage -a - -b ont.vs.ref.bam -mean > coverage.5kb.stats.tsv

Rscript --vanilla - <<'EOF'
rm(list = ls())
options(warn = 1)
options(stringsAsFactors = FALSE)
options(scipen = 999)

library(data.table)
library(ggplot2)

infile <- "coverage.5kb.stats.tsv"

df <- fread(infile, data.table = FALSE,
            col.names = c("chr","start","end","mean"))

df$mid <- (df$start + df$end) / 2
df$chr <- factor(df$chr, levels = unique(df$chr))

p_profile <- ggplot(df, aes(x = mid, y = mean, group = chr)) +
  geom_line(alpha = 0.5, linewidth = 0.4) +
  facet_wrap(~ chr, scales = "free_x", ncol = 4) +
  labs(x = "Genomic position (bp)", y = "Mean coverage (5 kb windows)") +
  coord_cartesian(ylim = c(0, 150)) +
  theme_bw()

ggsave("coverage.5kb.profile.per_chr.ycap150.png", p_profile, width = 12, height = 9, dpi = 150)
EOF

for chr in chrI chrII chrIII chrIV chrV chrVI chrVII chrVIII chrIX chrX chrXI chrXII chrXIII chrXIV chrXV chrXVI; do
  seqkit grep -r -p "${chr}$" parent1.renamed.fa > ${chr}.p1.fa
  seqkit grep -r -p "${chr}$" parent2.renamed.fa  > ${chr}.p2.fa
  cat ${chr}.p1.fa ${chr}.p2.fa > ${chr}.pair.fa
  rm ${chr}.p1.fa ${chr}.p2.fa
done

seqkit sort -l -r assembly.folded.fasta > assembly.folded.srt.fasta

mkdir -p nucmer

for chr in chrI chrII chrIII chrIV chrV chrVI chrVII chrVIII chrIX chrX chrXI chrXII chrXIII chrXIV chrXV chrXVI; do
  nucmer -l 250 assembly.folded.srt.fasta ${chr}.pair.fa -p assembly_vs_${chr}-ref1-ref2
  delta-filter -i 95 -l 5000 assembly_vs_${chr}-ref1-ref2.delta > assembly_vs_${chr}-ref1-ref2.filt.delta
  mummerplot --png --color -p assembly_vs_${chr}-ref1-ref2   assembly_vs_${chr}-ref1-ref2.delta
  mv assembly_vs_chr* nucmer
done
  rm *pair*

## controllare eventuali translocations 
nucmer -l 250 assembly.folded.srt.fasta parent1-parent2.renamed.fa -p assembly_vs_ref1-ref2
delta-filter -i 95 -l 5000 assembly_vs_ref1-ref2.delta > assembly_vs_ref1-ref2.filt.delta
mummerplot --png --color -p assembly_vs_ref1-ref2 assembly_vs_ref1-ref2.filt.delta
mv assembly_vs_* nucmer
