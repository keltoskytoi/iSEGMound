###################################LOAD DATA###################################
mounds_lit <- read.csv(file.path(path_analysis_data_literature_analysis,
                       "burial_mounds.csv"), header = TRUE, sep=",")
#read as tibble
mounds_lit <- as_tibble(mounds_lit)
names(mounds_lit)
#"ID" "Reference" "Year" "Data" "Method" "OoI" "Software_type"

str(mounds_lit)
#tibble [41 × 7] (S3: tbl_df/tbl/data.frame)
#$ ID           : int [1:41] 1 2 3 4 5 6 7 7 8 8 ...
#$ Reference    : chr [1:41] "Menze – Ur – Sherratt" "Menze – Mühl – Sherratt" "Menze – Ur" "De Boer" ...
#$ Year         : int [1:41] 2006 2007 2007 2007 2009 2014 2015 2015 2015 2015 ...
#$ Data         : chr [1:41] "Satellite" "Satellite" "Satellite" "LiDAR" ...
#$ Method       : chr [1:41] "Machine Learning" "Machine Learning" "Machine Learning" "Template Matching" ...
#$ OoI          : chr [1:41] "Tell mounds" "Tell mounds" "Tell mounds" "burial mounds" ...
#$ Software_type: chr [1:41] "FOSS" "FOSS" "FOSS" "proprietary" ...
################################################################################
mounds_lit_2 <- read.csv(file.path(path_analysis_data_literature_analysis,
                        "burial_mounds_short.csv"), header = TRUE, sep=",")
#read as tibble
mounds_lit_2 <- as_tibble(mounds_lit_2)
names(mounds_lit_2)
#"ID" "Reference" "Year" "Data" "OoI" "Software_type" "access"
str(mounds_lit_2)
#tibble [41 × 7] (S3: tbl_df/tbl/data.frame)
#$ ID           : int [1:41] 1 2 3 4 5 6 7 7 8 8 ...
#$ Reference    : chr [1:41] "Menze – Ur – Sherratt" "Menze – Mühl – Sherratt" "Menze – Ur" "De Boer" ...
#$ Year         : int [1:41] 2006 2007 2007 2007 2009 2014 2015 2015 2015 2015 ...
#$ Data         : chr [1:41] "Satellite" "Satellite" "Satellite" "LiDAR" ...
#$ Method       : chr [1:41] "Machine Learning" "Machine Learning" "Machine Learning" "Template Matching" ...
#$ OoI          : chr [1:41] "Tell mounds" "Tell mounds" "Tell mounds" "burial mounds" ...
#$ Software_type: chr [1:41] "FOSS" "FOSS" "FOSS" "proprietary" ...
#$ access       : chr [1:31] "n/a" "n/a" "n/a" "equation" ...
################################################################################
#-----------------------#WORKING WITH THE FIRST DATASET#-----------------------#
################################################################################
mounds_lit_filt <- mounds_lit[, c(3:7)]
#############################prepare/reshape the dataset########################
####----------------------------#using stats::ftable#-----------------------####
#check the different columns - also good for short and sweet summary:
table(mounds_lit_filt$Year)
#2006 2007 2009 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021
#2    5    1    2    2    1    5    5    2    5   12   13    7
table(mounds_lit_filt$Data)
#ALS Satellite       UAV
#42        18         2
table(mounds_lit_filt$Method)
#Deep Learning        GeOBIA      Geometric knowledge    PBIA   Template Matching
#         8             9                  25             13            7
table(mounds_lit_filt$OoI)
#burial mounds Monumental earthworks      Mound shell ring      Tell mounds
#35                     2                     9                    16
table(mounds_lit_filt$Software_type)
#FOSS         n/a proprietary
#35           4          23

#let's combine all separate tables together
all_combined <- table(mounds_lit_filt$Year, mounds_lit_filt$OoI, mounds_lit_filt$Method,
                      mounds_lit_filt$Data, mounds_lit_filt$Software_type)

#let's reshape the dataset as a flat contingency table (with 5 levels in our case):
all_combined_table <- stats::ftable(all_combined)
#just the head####
#                                                          FOSS No information proprietary

#2006 burial mounds         Deep Learning       LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           GeOBIA              LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Geometric knowledge LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Machine Learning    LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Template Matching   LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#     Monumental earthworks Deep Learning       LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           GeOBIA              LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Geometric knowledge LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Machine Learning    LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Template Matching   LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#     Mound shell ring      Deep Learning       LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           GeOBIA              LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Geometric knowledge LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Machine Learning    LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Template Matching   LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#     Tell mounds           Deep Learning       LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           GeOBIA              LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Geometric knowledge LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#                           Machine Learning    LiDAR         0              0           0
#                                               Satellite     1              0           0
#                                               UAV           0              0           0
#                           Template Matching   LiDAR         0              0           0
#                                               Satellite     0              0           0
#                                               UAV           0              0           0
#2007 burial mounds         Deep Learning       LiDAR         0              0           0
################################################################################
#####   now, change it back to a data frame to be able to plot the dataset  ####
all_combined_df <- as.data.frame(all_combined_table)
names(all_combined_df) <- c("Year", "OoI", "Method", "Data", "Software_type", "Freq")

names(all_combined_df)
#"Year" "OoI" "Method" "Data" "Software_type" "Freq"

################################################################################
####-----------------------#PLOT THE INVESTIGATED POINTS#-------------------####
################################################################################
####----------------------#stacked plots all_combined_df#-------------------####
#Methods used to detect mound-like objects in Automated Archaeological Remote Sensing between 2006 & 2021
ggplot(all_combined_df, aes(fill=Method, y=Freq, x=Year)) +
  geom_bar(position="stack", stat="identity") +
  ylim(0, 15) +
  scale_fill_manual(values=morris:::acanthus_palette) +
  ggtitle("Methods used to detect mound-like objects in Automated Archaeological Remote Sensing between 2006 & 2021") +
  theme_ipsum() +
  xlab("Year") +
  ylab("Number of studies")

ggplot(all_combined_df, aes(fill=Method, y=Freq, x=Method)) +
  geom_bar(position="dodge", stat="identity") +
  scale_fill_manual(values=morris:::acanthus_palette) +
  ggtitle("Methods used to detect mound-like objects in Automated Archaeological Remote Sensing between 2006 & 2021") +
  facet_wrap(~Year) +
  theme_ipsum() +
  theme(legend.position="none") +
  xlab("")
################################################################################
#####---------------------#PLOT THE SEPARATE METHODS#-----------------------####
methods <- table(mounds_lit_filt$Year, mounds_lit_filt$Method)

#let's reshape the dataset as a flat contingency table (with 5 levels in our case):
methods_table <- stats::ftable(methods)
methods_table_df <- as.data.frame(methods_table)
names(methods_table_df) <- c("Year", "Method", "Freq")
names(methods_table_df)

TM <- methods_table_df %>% filter(Method=="Template Matching")
ggplot(TM, aes(x=Year, y=Freq)) +
  geom_bar(stat="identity", fill ="#A68A59") +
  ylim(0, 5) +
  ggtitle("Use of Template Matching-based methods between 2006 & 2021") +
  theme_ipsum() +
  theme(legend.position="center") +
  xlab("Year") +
  ylab("Number of studies")

GKNB <- methods_table_df %>% filter(Method=="Geometric knowledge")
ggplot(GKNB, aes(y=Freq, x=Year)) +
  geom_bar(stat="identity", fill ="#70795E") +
  ylim(0, 7) +
  ggtitle("Use of Geometric knowledge-based methods between 2006 & 2021") +
  theme_ipsum() +
  theme(legend.position="none") +
  xlab("Year") +
  ylab("Number of studies")

GeOBIA <-methods_table_df %>% filter(Method=="GeOBIA")
ggplot(GeOBIA, aes(y=Freq, x=Year)) +
  geom_bar(stat="identity", fill ="#A9AF86") +
  ylim(0, 5) +
  ggtitle("Use of GeOBIA methods between 2006 & 2021") +
  theme_ipsum() +
  theme(legend.position="none") +
  xlab("Year") +
  ylab("Number of studies")

PBIA <-methods_table_df %>% filter(Method=="PBIA")
ggplot(PBIA, aes(y=Freq, x=Year)) +
  geom_bar(stat="identity", fill ="#BCC0AF") +
  ylim(0, 5) +
  ggtitle("Use of PBIA methods between 2006 & 2021") +
  theme_ipsum() +
  theme(legend.position="none") +
  xlab("Year") +
  ylab("Number of studies")

DL <-methods_table_df %>% filter(Method=="Deep Learning")
ggplot(DL, aes(y=Freq, x=Year)) +
  geom_bar(stat="identity", fill ="#43595E") +
  ylim(0, 5) +
  ggtitle("Use of Deep Learning methods between 2006 & 2021") +
  theme_ipsum() +
  theme(legend.position="none") +
  xlab("Year") +
  ylab("Number of studies")
################################################################################
#-----------------------#WORKING WITH THE SECOND DATASET#----------------------#
mounds_lit_2_filt <- mounds_lit_2[, c(3:7)]
################################################################################
all_combined_2 <- table(mounds_lit_2_filt$Year, mounds_lit_2_filt$OoI,
                      mounds_lit_2_filt$Data, mounds_lit_2_filt$Software_type,
                      mounds_lit_2_filt$access)

#let's reshape the dataset as a flat contingency table (with 5 levels in our case):
methods_table_2 <- stats::ftable(all_combined_2)
methods_table_df2 <- as.data.frame(methods_table_2)
names(methods_table_df2) <- c("Year", "OoI", "Data", "Software_type", "access", "Freq")
names(methods_table_df2)

#Data types used to detect mound-like objects in Automated Archaeological Remote Sensing between 2006 & 2021
ggplot(methods_table_df2, aes(fill=Data, y=Freq, x=Year)) +
  geom_bar(position="stack", stat="identity") +
  ylim(0, 7) +
  scale_fill_manual(values=morris:::peacock_palette) +
  ggtitle("Data types used to detect mound-like objects in Automated Archaeological Remote Sensing between 2006 & 2021") +
  theme_ipsum() +
  xlab("Year") +
  ylab("Number of studies")

#Software Types used to detect mound-like objects in Automated Archaeological Remote Sensing between 2006 & 2021
ggplot(methods_table_df2, aes(fill=Software_type, y=Freq, x=Year)) +
  geom_bar(position="stack", stat="identity") +
  ylim(0, 7) +
  scale_fill_manual(values=morris:::flowers_palette) +
  ggtitle("Software Types used to detect mound-like objects in Automated Archaeological Remote Sensing between 2006 & 2021") +
  theme_ipsum() +
  xlab("Year") +
  ylab("Number of studies")

#Specific OoI's to detect by automated Archaeological Remote Sensing methods between 2006 & 2021
ggplot(methods_table_df2, aes(fill=OoI, y=Freq, x=Year)) +
  geom_bar(position="stack", stat="identity") +
  ylim(0, 7) +
  scale_fill_manual(values=morris:::holland_palette) +
  ggtitle("Objects of Interest in Automated Archaeological Remote Sensing between 2006 & 2021") +
  theme_ipsum() +
  xlab("Year") +
  ylab("Number of studies")

#access to different parts of the studies between 2006 & 2021
ggplot(methods_table_df2, aes(fill=access, y=Freq, x=Year)) +
  geom_bar(position="stack", stat="identity") +
  ylim(0, 7) +
  scale_fill_manual(values=morris:::strawberry_palette ) +
  ggtitle("Access of any parts of studies investigated between 2006 & 2021") +
  theme_ipsum() +
  xlab("Year") +
  ylab("Number of studies")
