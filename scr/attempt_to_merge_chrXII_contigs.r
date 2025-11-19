# Title:
# Author: Nicolò T.
# Status: Draft

# Comments:

# Options ----

rm(list = ls())
options(warn = 1)
options(stringsAsFactors = F)
gc()
gcinfo(FALSE)
options(scipen=999)

# Variables ----

# baseDir <- '/home/ntellini/t2tyDNA/yS1080'
#ind="yS1080"


argsVal <- commandArgs(trailingOnly = T)
baseDir <- as.character(argsVal[1])
ind <- as.character(argsVal[2])
setwd(baseDir)

# Libraries ----

library(seqinr)

# body ----

df <- read.table(paste0("tmp/ylr163c.fasta36.txt"))

print(paste0(df[1,2],": is the contig to be joined to chrXII"))
fasta <- read.fasta(paste0("tmp/",ind,".genome1.fa"),as.string = F,forceDNAtolower = F,set.attributes = F)

if (df[1,8] < df[1,7]) {
  print("The conting is in the CORRECT orientation.")
  print(paste0("Merging chrXII and ",df[1,2]))
  fasta[["XII"]] <- c(fasta[["XII"]],fasta[[df[1,2]]])
  fasta[df[1,2]] <- NULL 
  write.fasta(sequences = fasta,names = names(fasta),file.out = paste0("tmp/",ind,".genome.fa"),open = "w",nbchar = 60)
} else if (df[1,8] > df[1,7]){
  print("The conting is in the INCORRECT orientation.")
  print(paste0("reverse complement of ",df[1,2]))
  contig <- comp(rev(fasta[[df[1,2]]]))
  print(paste0("Merging chrXII and ",df[1,2]))
  fasta[[df[1,2]]] <- contig
  fasta[["XII"]] <- c(fasta[["XII"]],fasta[[df[1,2]]])
  fasta[df[1,2]] <- NULL 
  write.fasta(sequences = fasta,names = names(fasta),file.out = paste0("tmp/",ind,".genome.fa"),open = "w",nbchar = 60)
}
