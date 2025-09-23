# Wed Aug  6 15:55:25 2025 

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

#  baseDir <- '/home/nico/nas/A10/tlo'
#  ind="G10"


argsVal <- commandArgs(trailingOnly = T)
baseDir <- as.character(argsVal[1])
ind <- as.character(argsVal[2])
setwd(baseDir)

# Libraries ----

library(ggplot2)
library(data.table)
library(ggpubr)

# body ----

file.remove("listemptychrsextremities.txt")
files <- list.files(recursive = T, pattern = "clean")

all_tel <- data.frame()
for (i in files) {
  df_t <-  fread(i,data.table = F)
  if (nrow(df_t) >= 1) {
    df_t[,"V5"] <- ind
    df_t$file <- i
    chr_coord <- gsub(".clean.txt","",gsub("telo-","",sapply(strsplit(i,"/"),"[[",2)))
    df_t$chr_coord <- chr_coord
    all_tel <- rbind(all_tel,df_t)
  } else {
    cat(paste0("The file: ",i, " it is empty.\n"),file = "listemptychrsextremities.txt",append = T)
  }
}  

### save this file for statistics ----
all_tel_forstats <- all_tel
all_tel_forstats$V4 <- NULL
all_tel_forstats$file <- NULL
all_tel_forstats$chr <- sapply(strsplit(all_tel_forstats$chr_coord ,"_"),"[[",1)
all_tel_forstats$placement <- sapply(strsplit(all_tel_forstats$chr_coord ,"_"),"[[",2)
all_tel_forstats[,"side"] <- "R"
all_tel_forstats[grep("1-20000",all_tel_forstats$placement),"side"] <- "L"
all_tel_forstats$chr_coord <- NULL
all_tel_forstats$placement <- NULL
colnames(all_tel_forstats) <- c("read_name","start","end","strain_name","chr","side")
all_tel_forstats$tel_len <-  abs(all_tel_forstats$end - all_tel_forstats$start) + 1
write.table(all_tel_forstats,file = "tel_info_for_stats.txt",append = F,quote = F,sep = "\t",row.names = F,col.names = F)

#### ----

all_tel$V5 <- NULL

all_tel$diff <- abs(all_tel[,2] - all_tel[,3]) + 1
all_tel[grep("-1-20000",all_tel$chr_coord),"tel_pos"] <- "L"
all_tel[grep("-1-20000",all_tel$chr_coord,invert = T),"tel_pos"] <- "R"
all_tel$chrs <- sapply(strsplit(all_tel$chr_coord,"-"),"[[",1)
print(paste0("before len filt: ",nrow(all_tel)))
all_tel[all_tel$tel_pos == "L","diff"] <- -1 * all_tel[all_tel$tel_pos == "L","diff"]
all_tel <- all_tel[all_tel$diff >= -1000 & all_tel$diff <= 1000,]
print(paste0("after len filt: ",nrow(all_tel)))
cat(paste0("A step of filtering < -1000 and > 1000 bp is applyed for telomere legth"),file = "readme.txt",append = T)

vline_dfR <- unique(all_tel[all_tel$tel_pos == "R", c("chrs", "tel_pos")])
vline_dfR$xintercept <- 345
vline_dfL <- unique(all_tel[all_tel$tel_pos == "L", c("chrs", "tel_pos")])
vline_dfL$xintercept <- -345
all_tel[,"colors"] <- "darkred"
v_left <- vector(mode = "character",length = 10)
v_rigth <- vector(mode = "character",length = 10)

v_left[7] <- -1000
v_left[8] <- "L"
v_left[9] <- "I"
v_left[10] <-  NA

v_rigth[7] <- 1000
v_rigth[8] <- "R"
v_rigth[9] <- "I"
v_rigth[10] <- NA

borders <- as.data.frame(rbind(v_rigth,v_left))
colnames(borders) <- colnames(all_tel)
borders[,7] <- as.numeric(borders[,7])

all_tel$chrs <-gsub("chr","", gsub("_RagTag","",all_tel$chrs) )
vline_dfL$chrs <- gsub("chr","", gsub("_RagTag","",vline_dfL$chrs))
vline_dfR$chrs <- gsub("chr","", gsub("_RagTag","",vline_dfR$chrs))

contigs <- unique(grep("contig_",all_tel$chrs,value = T))

lev <- c("I","II","III","IV","V","VI",
         "VII","VIII","IX","X","XI","XII","XIII",
         "XIV","XV","XVI",contigs)
all_tel$chrs   <- factor(all_tel$chrs,   levels = lev)
vline_dfL$chrs <- factor(vline_dfL$chrs, levels = lev)  # if present
vline_dfR$chrs <- factor(vline_dfR$chrs, levels = lev)  # if present
borders$chrs   <- factor(borders$chrs,   levels = lev)  # IMPORTANT

setDT(all_tel)

summary_plot <- as.data.frame(table(all_tel$chrs,all_tel$tel_pos))
summary_plot[summary_plot$Var2 == "L","xval"] <- -950
summary_plot[summary_plot$Var2 == "R","xval"] <- 950
colnames(summary_plot)[1] <- "chrs"
colnames(summary_plot)[2] <- "tel_pos"

plot_tel_dist <- ggplot() + 
  geom_vline(data = vline_dfR, mapping = aes(xintercept = xintercept), color = "darkviolet",linewidth=1) +
  geom_vline(data = vline_dfL, mapping = aes(xintercept = xintercept), color = "darkviolet",linewidth=1) +
  geom_jitter(all_tel,mapping = aes(x=diff,chrs),width = 0,height = 0.2,alpha=0.5,color="black")+
  geom_boxplot(all_tel,mapping=aes(diff,chrs),alpha=0.3,color="red",fill="darkred",outlier.colour = NA) +
  geom_text(summary_plot,mapping=aes(xval,chrs,label=paste0("(",Freq,")"))) +
  geom_point(borders,mapping = aes(x=diff,chrs),color=NA)+
  facet_grid(rows = vars(chrs), cols = vars(tel_pos), scales = "free", drop = FALSE, as.table = TRUE) +
  scale_x_continuous(n.breaks =10,labels = function(x) abs(x))+
  theme_bw() +
  theme(axis.text.y = element_blank(),axis.ticks.y = element_blank()) +
  ggtitle(label =  ind) +
  xlab("TEL len")


ggsave(plot_tel_dist, 
       filename =  paste0(baseDir,"/",ind,".tlodist.pdf"),
       device = "pdf",
       height = 10, width = 6, units = "in")

fn <- paste0(baseDir,"/Rplots.pdf")
if (file.exists(fn)) {
  file.remove(fn)
}

median_df <- all_tel[,median(diff),by = tel_pos]
L_median <- as.numeric(median_df[median_df$tel_pos =="L",][,2])
R_median <- as.numeric(median_df[median_df$tel_pos =="R",][,2])

p_dens_LR <- ggplot() + 
  geom_density(all_tel,mapping=aes(diff,fill=tel_pos),alpha=0.5)  +
  geom_vline(mapping = aes(xintercept = L_median),linewidth=0.5) + 
  geom_vline(mapping = aes(xintercept = R_median),linewidth=0.5) +
  geom_text(mapping=aes((L_median)-150,y = 0.005,label=paste0("(median:\n",abs(L_median),")"))) +
  geom_text(mapping=aes((R_median)+150,y = 0.005,label=paste0("(median:\n",abs(R_median),")"))) +
  scale_y_continuous(labels = function(x)x*1000) +
  scale_x_continuous(n.breaks =10,labels = function(x) abs(x)) +
  ylab("Density (x10^-3)") +
  xlab("Telomere length (bp)") +
  theme_bw()

p_hist_LR <- ggplot() + 
  geom_histogram(all_tel,mapping=aes(diff,fill=tel_pos),alpha=0.8,binwidth=20)  +
  geom_vline(mapping = aes(xintercept = L_median),linewidth=0.5) + 
  geom_vline(mapping = aes(xintercept = R_median),linewidth=0.5) +
  geom_text(mapping=aes((L_median)-150,y = 0.005,label=paste0("(median:\n",abs(L_median),")"))) +
  geom_text(mapping=aes((R_median)+150,y = 0.005,label=paste0("(median:\n",abs(R_median),")"))) +
  scale_x_continuous(n.breaks =10,labels = function(x) abs(x)) +
  ylab("Counts") +
  xlab("Telomere length (bp)") +
  theme_bw()

all_tel$diff <- abs(all_tel$diff)
median_df <- all_tel[,median(diff),by = c("chrs","tel_pos")]
median_of_medians <- median(median_df$V1)

p_dens <- ggplot() + 
  geom_density(all_tel,mapping=aes(diff),alpha=0.5)  +
  geom_vline(mapping = aes(xintercept = median_of_medians),linewidth=0.5)  +
  geom_text(mapping=aes((median_of_medians)-100,y = 0.005,label=paste0("(median_of_medians:\n",abs(median_of_medians),")"))) +
  scale_y_continuous(labels = function(x)x*1000) +
  ylab("Density (x10^-3)") +
  xlab("Telomere length (bp)") +
  theme_bw()

p_histo <- ggplot() + 
  geom_histogram(all_tel,mapping=aes(diff),alpha=0.5,binwidth=20)  +
  geom_vline(mapping = aes(xintercept = median_of_medians),linewidth=0.5)  +
  geom_text(mapping=aes((median_of_medians)-100,y = 0.005,label=paste0("(median_of_medians:\n",abs(median_of_medians),")"))) +
  ylab("Counts") +
  xlab("Telomere length (bp)") +
  theme_bw()

panels <- ggarrange(p_dens,p_histo,p_dens_LR,p_hist_LR,
  ncol = 2,nrow = 2,labels = ind)

ggsave(panels, 
       filename =  paste0(baseDir,"/",ind,".summarypanels.pdf"),
       device = "pdf",
       height = 10, width = 10, units = "in")

fn <- paste0(baseDir,"/Rplots.pdf")
if (file.exists(fn)) {
  file.remove(fn)
}

setDT(all_tel)

median_df <- all_tel[,median(diff),by = "chrs"]
sd_df <- all_tel[,sd(diff),by = "chrs"]
mean_df <- all_tel[,mean(diff),by = "chrs"]
df_list <- list(mean_df, sd_df, median_df)
merged_df <- Reduce(function(x, y) merge(x, y, by = "chrs"), df_list)
colnames(merged_df) <- c("chrs","mean","sd","median")
write.table(merged_df,file = "perchromosome-stats.telolen.txt",append = F,quote = F,sep = "\t",row.names = F,col.names = F)


median_df <- all_tel[,median(diff),by = c("chrs","tel_pos")]
sd_df <- all_tel[,sd(diff),by = c("chrs","tel_pos")]
mean_df <- all_tel[,mean(diff),by = c("chrs","tel_pos")]
df_list <- list(mean_df, sd_df, median_df)
merged_df <- Reduce(function(x, y) merge(x, y, by = c("chrs","tel_pos")), df_list)
colnames(merged_df) <- c("chrs","side","mean","sd","median")
write.table(merged_df,file = "perchromosomeperside-stats.telolen.txt",append = F,quote = F,sep = "\t",row.names = F,col.names = F)
