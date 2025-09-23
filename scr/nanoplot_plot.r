# Fri May  9 14:02:33 2025 

# Title: nanoplot densityplot 2D
# Author: Nicolò T.
# Status: Complete
# Comments: read length vs read quality

# Options ----

rm(list = ls())
options(warn = 1)
options(stringsAsFactors = F)
gc()
gcinfo(FALSE)
options(scipen=999)

# Variables ----

# baseDir <- '/home/ntellini/proj/SGRP5/denovoassembliesont/sunp2/FKS1-assemblies/pipeline-v5'
# allDir <- list.dirs()
# allFiles <- list.files()
# ind="yS1161"

argsVal <- commandArgs(trailingOnly = T)
baseDir <- as.character(argsVal[1])
ind <- as.character(argsVal[2])
setwd(baseDir)

# Libraries ----

library(ggplot2)
library(data.table)
library(viridis)
library(ggExtra)

# body ----

df <- fread(paste0(baseDir,"/seq/nanoplot_",ind,"/NanoPlot-data.tsv.gz"))

p <- ggplot(df, aes(lengths, quals)) + 
  geom_point(alpha = 0.2) +
  geom_density_2d_filled(contour_var = "count", bins = 10, alpha = 0.7) + 
  theme_bw() +
  theme(legend.position = "none") +
  scale_x_continuous(n.breaks = 20) +
  scale_fill_manual(values = c(
    "#440154", "#482777", "#3E4989", "#31688E", "#26828E",
    "#1F9E89", "#35B779", "#6DCD59", "#B4DE2C", "#FDE725"
  ))


q <- ggMarginal(p,type = "density",fill="darkgreen",alpha=0.5)


ggsave(q, 
       filename =  paste0(baseDir,"/seq/nanoplot_",ind,"/density_plot.pdf"),
       device = "pdf",
       height = 10, width = 10, units = "in")

fn <- paste0(baseDir,"/Rplots.pdf")
if (file.exists(fn)) {
    file.remove(fn)
}
