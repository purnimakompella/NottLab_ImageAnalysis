library(dplyr)
library(lubridate)
install.packages("stringr")
library(stringr)
library(ggplot2)

log_filepath = "/Users/julio/Desktop/220517_VolumeAnalysis_Log.txt"
conn <- file(log_filepath,open="r")
linn <-readLines(conn, warn=FALSE)
samplesrow <- 1
GCrow <- 1
FCrow <- 1
samples <- list()
GCVols <- list()
FCVols <- list()
for (i in 1:length(linn)){
  #print(linn[i])
  if (grepl("Processing", linn[i])){
    sample <- linn[i]
    print(sample)
    if (grepl("Processing: /Volumes/NOTT OMX SR/Purnima/220324/SIR/untitled folder/", linn[i])){
      sample_trimmed <- str_remove(sample, "Processing: /Volumes/NOTT OMX SR/Purnima/220324/SIR/untitled folder/")
    }
    else if (grepl("Processing: /Volumes/NOTT OMX SR/Purnima/220324/SIR/", linn[i])){
      sample_trimmed <- str_remove(sample, "Processing: /Volumes/NOTT OMX SR/Purnima/220324/SIR/")
    }
    else if (grepl("Processing: /Volumes/NOTT OMX SR/Purnima/SIR/", linn[i])){
      sample_trimmed <- str_remove(sample, "Processing: /Volumes/NOTT OMX SR/Purnima/SIR/")
    }
    #sample_trimmed <- str_remove(sample, "Processing: /Volumes/NOTT OMX SR/Purnima/220324/SIR/untitled folder/")
    #sample_trimmed <- str_remove(sample, "Processing: /Volumes/NOTT OMX SR/Purnima/220324/SIR/")
    #sample_trimmed <- str_remove(sample, "Processing: /Volumes/NOTT OMX SR/Purnima/SIR/")
    print(sample_trimmed)
    samples[samplesrow] <- sample_trimmed
    samplesrow <- samplesrow + 1
  }
  else if (grepl("GC", linn[i])){
    GCVol <- linn[i]
    GCVol_trimmed <- str_remove(GCVol, "GC Volume:")
    GCVols[GCrow] <- GCVol_trimmed
    GCrow <- GCrow + 1
  }
  else if (grepl("Nucleolus", linn[i])){
    GCVol <- linn[i]
    GCVol_trimmed <- str_remove(GCVol, "Nucleolus Volume:")
    GCVols[GCrow] <- GCVol_trimmed
    GCrow <- GCrow + 1
  }
  else if (grepl("FC", linn[i])){
    FCVol <- linn[i]
    FCVol <- str_to_upper(FCVol)
    FCVol_trimmed <- str_remove(FCVol, "FC VOLUME:")
    #FCVol_trimmed <- str_remove(FCVol, "FC volume: ")
    #print(FCVol)
    #print(FCVol_trimmed)
    FCVols[FCrow] <- FCVol_trimmed
    FCrow <- FCrow + 1
  }
}
close(conn)
#rm(df)
df  <- do.call(rbind.data.frame, samples)
names(df)[1] <- "Sample"
df  <- cbind(df, do.call(rbind.data.frame, GCVols))
names(df)[2] <- "GCVolume"
df  <- cbind(df, do.call(rbind.data.frame, FCVols))
names(df)[3] <- "FCVolume"

df <- as.data.frame(apply(df, 2, str_remove_all, " ")) #remove all spaces from df
df[ df == "N/A" ] <- NA #change character N/A to NA so those rows can be omitted
df$CellLine <- sapply(str_split(df$Sample,"_"), "[", 2) #get cell line
df$Construct <- sapply(str_split(df$Sample,"_"), "[", 3) #get construct
#clean up construct name for consistency
df$Construct <- gsub("NG-","",as.character(df$Construct))
df$Construct <- gsub("mTurbo","Turbo",as.character(df$Construct))
df$Construct <- gsub("-mNG","",as.character(df$Construct))

#convert character to numeric for plotting
df$GCVolume <- as.numeric(as.character(df$GCVolume))
df$FCVolume <- as.numeric(as.character(df$FCVolume))

sapply(df, class) #check class

df_clean <- na.omit(df)

pdf(file = "/Volumes/NOTT OMX SR/Purnima/SIR/Plots/220518_VolumeAnalysis.pdf")
ggplot(df_clean, aes(x=GCVolume, y=FCVolume, color=as.factor(Construct))) + 
  geom_point() + 
  facet_grid(.~CellLine) + 
  theme_classic()
ggplot(df_clean, aes(x=log10(GCVolume), y=log10(FCVolume), color=as.factor(Construct))) + 
  geom_point() + 
  facet_grid(.~CellLine) + 
  theme_classic()
ggplot(df_clean, aes(x=log10(GCVolume), y=log10(FCVolume), color=as.factor(Construct))) + 
  geom_violin() + 
  facet_grid(.~CellLine) + 
  theme_classic()
ggplot(df_clean, aes(x=GCVolume, y=FCVolume, color=as.factor(Construct))) + 
  geom_point() + 
  facet_grid(.~CellLine) + 
  theme_classic() +
  ylim(0,50) +
  xlim(0,1000)

df_noRPE1 <- subset(df_clean, CellLine != "RPE1")
ggplot(df_noRPE1, aes(x=GCVolume, y=FCVolume, color=as.factor(Construct))) + 
  geom_point() + 
  facet_grid(.~CellLine) + 
  theme_classic() +
  ylim(0,50) +
  xlim(0,1000)

df_noRPE1_noTurbo <- subset(df_noRPE1, !(grepl("Turbo", df_noRPE1$Construct, fixed=TRUE))) #remove all Turbo construct
ggplot(df_noRPE1_noTurbo, aes(x=GCVolume, y=FCVolume, color=as.factor(Construct))) + 
  geom_point() + 
  #facet_grid(.~CellLine) + 
  #ylim(0,50) +
  #xlim(0,1000) +
  theme_classic() 

ggplot(df_noRPE1_noTurbo, aes(x=log10(GCVolume), y=log10(FCVolume), color=as.factor(Construct))) + 
  geom_point() + 
  #facet_grid(.~CellLine) + 
  #ylim(0,50) +
  #xlim(0,1000) +
  theme_classic()

ggplot(df_noRPE1_noTurbo, aes(x=log10(GCVolume), y=log10(FCVolume), color=as.factor(Construct))) + 
  geom_violin() + 
  #facet_grid(.~CellLine) + 
  #ylim(0,50) +
  #xlim(0,1000) +
  theme_classic() 
dev.off()
