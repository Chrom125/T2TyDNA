# Thu Sep  4 14:33:09 2025 

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

#baseDir <- '/home/ntellini/t2tydna/pipeline-v6/tmp'
#str <- "yS199"

argsVal <- commandArgs(trailingOnly = T)
baseDir <- as.character(argsVal[1])
str <- as.character(argsVal[2])

setwd(baseDir)

# Libraries ----

library(data.table)

# body ----

df_ann_emapper <- fread(cmd = paste0("grep -v '#' ",str,"_annotation.emapper.annotations"),sep = "\t",data.table = F,fill=TRUE)
df_ann_emapper <- df_ann_emapper[,c(1,2,4,6,9)]

df_ann_emapper[,"taxid"] <- sapply(strsplit(df_ann_emapper[,2],split = "\\."),"[[",1)
df_ann_emapper[,"gene_name"] <- sapply(strsplit(df_ann_emapper[,2],split = "\\."),"[[",2)

df_cds <- fread("yS199.CDS.gff3",data.table = F)
df_cds$matching_name <- gsub("\\.","_",sapply(strsplit(df_cds[,ncol(df_cds)],"="),"[[",3) )

merged_tab <- base::merge(df_cds,df_ann_emapper,by.x ="matching_name",by.y = "V1",all = T)

merged_tab[,1] <- NULL
merged_tab$annotation <- apply(merged_tab[,c(9,14,15,12,11),], 1, function(x) paste(collapse = ";",sep = ";",x))
merged_tab[,c(9,14,15,12,11)] <- NULL
merged_tab[,6] <- "."
merged_tab[,8] <- "."
merged_tab[,c(9,10)] <- NULL
merged_tab[,2] <- str

write.table(merged_tab,file = paste0(str,".cdsclean.gff3"),append = T,quote = F,sep = "\t",col.names = F,row.names = F)
