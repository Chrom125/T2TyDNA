rm(list = ls())
options(stringsAsFactors = F)

# settings ----------------------------------------------------------------

# arguments
argsVal <- commandArgs(trailingOnly = T)
asmdir <- argsVal[1]
tmpdir <- argsVal[3]
samp <- argsVal[2]

 # asmdir <- '/home/ntellini/proj/SGRP5/denovoassembliesont/sunp2/FKS1-assemblies/pipeline-v3/asm'
 # tmpdir <- '/home/ntellini/proj/SGRP5/denovoassembliesont/sunp2/FKS1-assemblies/pipeline-v3/tmp'
 # samp <- "yS366"

library(seqinr)
library(data.table)

setwd(tmpdir)

files_cen <- paste0(samp,".cen-pos.flye.txt")
for (i in files_cen) {
  
  assembler <- sapply(strsplit(i,"\\."),"[[",3)
  fasta <- read.fasta(paste0(samp,".medaka.",assembler,".final.fasta"),seqtype = "DNA",forceDNAtolower = F, set.attributes = F,as.string = T)
  
  tb <- fread(i,data.table = F)
  tb[,1] <- sapply(strsplit(tb[,1],":"),"[[",1)
  tb[,1] <- gsub("chr","",tb[,1])
  
  if ( length(unique(tb[,2])) == 16 | length(unique(tb[,2])) > 16 ) {
    print(paste0("The ",i," genome has ", length(unique(tb[,2])), " unique contig hits. So each centromere has been assigned to a DIFFERENT contig. Nice!"))
    
    for (j in 1:nrow(tb) ) {
      names(fasta)[names(fasta) == tb[j,2] ] <- tb[j,1]
    }
    
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
                ,open = "w",file.out = paste0(samp,".",assembler,".clean.fa")) 
  } 
  else if ( length(unique(tb[,2])) < 16 ) {
    print(paste0("WARNING: The ",i," genome has ", length(unique(tb[,2])), " different contig hits. So different centromers have been assigned to the SAME contig."))
    
    contig_hit <- names(table(tb[,2])[table(tb[,2]) != 1])
    
    for (j in contig_hit) {
      
      new_1 <- paste(tb[tb[,2] == j,1],sep = "_",collapse = "_")
      new_2 <- unique(tb[tb[,2] == j,2])
      
      tb <- tb[-c(which(tb[,2] == j)),]
      tb[nrow(tb)+1,1] <- new_1
      tb[nrow(tb),2] <- new_2
    }
    
    for (j in 1:nrow(tb) ) {
      names(fasta)[names(fasta) == tb[j,2] ] <- tb[j,1]
    }
    
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
                ,open = "w",file.out = paste0(samp,".",assembler,".clean.fa")) 
  }
}
