rm(list = ls())
options(stringsAsFactors = F)

# settings ----------------------------------------------------------------

# arguments
argsVal <- commandArgs(trailingOnly = T)
tmpdir <- argsVal[1]
samp <- argsVal[2]

# asmdir <- '/home/ntellini/proj/SGRP5/denovoassembliesont/sunp2/FKS1-assemblies/pipeline-v3/asm'
#tmpdir <- '/home/ntellini/t2tydna/pipeline-v6/tmp'
#samp <- "yS1080"

library(seqinr)

setwd(tmpdir)

fasta <- read.fasta("goodorderchrs.fa",seqtype = "DNA",forceDNAtolower = F, set.attributes = F,as.string = T)


  fasta_headers <- names(fasta)
  
  # Function to extract sorting keys
  extract_key <- function(header) {
    if (header == "chrMT") {
      return(100) 
    }
    if (grepl("contig_", header)) {
      return(200) 
    }
    roman_to_int <- c(
      "I" = 1, "II" = 2, "III" = 3, "IV" = 4, "V" = 5, "VI" = 6, 
      "VII" = 7, "VIII" = 8, "IX" = 9, "X" = 10, "XI" = 11,
      "XII" = 12, "XIII" = 13, "XIV" = 14, "XV" = 15, "XVI" = 16
    )
    roman <- gsub("chr", "", header)
    return(as.numeric(roman_to_int[roman]))
  }
  
  sorting_keys <- sapply(fasta_headers, extract_key)
  reordered_headers <- fasta_headers[order(sorting_keys)]
  reordered_fasta <- fasta[reordered_headers]
  
  write.fasta(sequences = reordered_fasta,names = names(reordered_fasta),nbchar = 60
              ,open = "w",file.out = paste0(samp,".genome1.fa")) 
  
file.remove("goodorderchrs.fa")
