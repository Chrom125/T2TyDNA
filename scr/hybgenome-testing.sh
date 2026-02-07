# good luck !
nanoreads=SRR18661818.fastq.gz  # importante name.fastq.gz
parent1=S288C.asm01.HP0.nuclear_genome.tidy.fa # importante name.blablabla
parent2=CBS7001.asm01.HP0.nuclear_genome.tidy.fa

hifiasm -o assembly --dual-scaf -t20 --ont  $nanoreads

awk '/^S/{print ">"$2"\n"$3}' assembly.bp.hap1.p_ctg.gfa  | fold > assembly.bp.hap1.p_ctg.fa
awk '/^S/{print ">"$2"\n"$3}' assembly.bp.hap2.p_ctg.gfa  | fold > assembly.bp.hap2.p_ctg.fa

busco -i assembly.bp.hap1.p_ctg.fa -l saccharomycetes_odb10 -m genome -c 8 --out_path busco -o assembly.bp.hap1.p_ctg.busco
busco -i assembly.bp.hap2.p_ctg.fa -l saccharomycetes_odb10 -m genome -c 8 --out_path busco -o assembly.bp.hap2.p_ctg.busco

p1=$(echo $parent1 | cut -d"." -f1)
p2=$(echo $parent2 | cut -d"." -f1)

sed "s/^>/>${p1}_/" $parent1 > parent1.renamed.fa
sed "s/^>/>${p1}_/" $parent2 > parent2.renamed.fa 

for chr in chrI chrII chrIII chrIV chrV chrVI chrVII chrVIII chrIX chrX chrXI chrXII chrXIII chrXIV chrXV chrXVI; do
  seqkit grep -r -p "${chr}$" parent1.renamed.fa > ${chr}.p1.fa
  seqkit grep -r -p "${chr}$" parent2.renamed.fa  > ${chr}.p2.fa
  cat ${chr}.p1.fa ${chr}.p2.fa > ${chr}.pair.fa
  rm ${chr}.p1.fa ${chr}.p2.fa
done

cat assembly.bp.hap1.p_ctg.fa assembly.bp.hap2.p_ctg.fa > hap1-hap2.fa

seqkit sort -l -r hap1-hap2.fa > hap1-hap2.srt.fa

for chr in chrI chrII chrIII chrIV chrV chrVI chrVII chrVIII chrIX chrX chrXI chrXII chrXIII chrXIV chrXV chrXVI; do
  nucmer -l 250 hap1-hap2.fa ${chr}.pair.fa -p hap1-hap2_vs_${chr}-ref1-ref2
  mummerplot --png --color -p hap1-hap2_vs_${chr}-ref1-ref2   hap1-hap2_vs_${chr}-ref1-ref2.delta
done
