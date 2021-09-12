################################################################################
####-------------#1.READ MOUNDS DOBIAT 1994 IN THE TRAIN AREA#---------------####
burial_mounds_5 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994.shp"))
burial_mounds_7 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "7_Dobiat_1994.shp"))
burial_mounds_14 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "14_Dobiat_1994.shp"))
burial_mounds_35 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994.shp"))
################################################################################
#-----------------------#2.PREPARE DOBIAT 1994 MOUNDS#-------------------------#
################################################################################
####-------------------------#MOUND GROUPS 5+35#----------------------------####
mounds_5_35 <- bind(burial_mounds_5, burial_mounds_35)
mapview(mounds_5_35)
rgdal::writeOGR(obj=mounds_5_35, dsn = "C:/Users/kelto/Documents/repRCHrs/tmp",
                layer ="segments", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
####-------------------------#COMPUTE SHP INDEX#----------------------------####
compute_shape_index_SAGA(segments=paste0(path_tmp, "segments.shp"),
                         tmp=paste0(path_tmp),
                         index=paste0(path_tmp, "segments.shp"),
                         gyros=1,
                         feret=1,
                         feret_dirs=18)
segments <-readOGR(paste0(path_tmp, "segments.shp"))
mapview(segments) # you can check the attribute table
#the  ID  starts with 0, so we will  change that and assign 1:10
segments$ID <- c(1:10)
segments$ID
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments@data$compactness <- (sqrt(4*segments@data$A/pi))/segments@data$P
segments@data$roundness <- (4*segments@data$A)/(pi*segments@data$Fmax)
segments@data$elongation <- segments@data$Fmax/segments@data$Fmin
#---------------------#EXPORT TRAIN SEGMENTS WITH DESCRIPTORS#-----------------#
rgdal::writeOGR(obj=segments, dsn = "C:/Users/kelto/Documents/repRCHrs/analysis/data/burial_mounds_Dobiat_1994",
                layer ="mounds_5_35", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
mounds_5_35 <-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "mounds_5_35.shp"))
mapview(mounds_5_35)
#####-----------------------#REFERENCE DESCRIPTORS USED#--------------------####
min(mounds_5_35$A) #74.08783
max(mounds_5_35$A) #793.202
min(mounds_5_35$Sphrcty) #0.9747955
max(mounds_5_35$Sphrcty) #0.9912325
min(mounds_5_35$Shp_Ind) #1.008845
max(mounds_5_35$Shp_Ind) #1.025856
min(mounds_5_35$elongtn) #1.058743
max(mounds_5_35$elongtn) #1.200961
min(mounds_5_35$cmpctns) #0.3102871
max(mounds_5_35$cmpctns) #0.3155191
####-------------------------#ALL TEST MOUNDS#------------------------------####
all_train_mounds <- bind(burial_mounds_5, burial_mounds_7, burial_mounds_14, burial_mounds_35)
mapview(all_train_mounds)
rgdal::writeOGR(obj=all_train_mounds, dsn = "C:/Users/kelto/Documents/repRCHrs/tmp",
                layer ="segments", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
####-------------------------#COMPUTE SHP INDEX#----------------------------####
compute_shape_index_SAGA(segments=paste0(path_tmp, "segments.shp"),
                         tmp=paste0(path_tmp),
                         index=paste0(path_tmp, "segments.shp"),
                         gyros=1,
                         feret=1,
                         feret_dirs=18)
segments <-readOGR(paste0(path_tmp, "segments.shp"))
mapview(segments) # you can check the attribute table
#the  ID  starts with 0, so we will  change that and assign 1:38
segments$ID <- c(1:38)
segments$ID
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments@data$compactness <- (sqrt(4*segments@data$A/pi))/segments@data$P
segments@data$roundness <- (4*segments@data$A)/(pi*segments@data$Fmax)
segments@data$elongation <- segments@data$Fmax/segments@data$Fmin
#---------------------#EXPORT TRAIN SEGMENTS WITH DESCRIPTORS#-----------------#
rgdal::writeOGR(obj=segments, dsn = "C:/Users/kelto/Documents/repRCHrs/analysis/data/burial_mounds_Dobiat_1994",
                layer ="all_train_mounds", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
all_train_mounds<-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "all_train_mounds.shp"))
mapview(all_train_mounds)
#####-----------------------#REFERENCE DESCRIPTORS USED#--------------------####
min(all_train_mounds$A) #74.08783
max(all_train_mounds$A) #793.202
min(all_train_mounds$Sphrcty) #0.9731846
max(all_train_mounds$Sphrcty) #0.9912325
min(all_train_mounds$Shp_Ind) #1.008845
max(all_train_mounds$Shp_Ind) #1.027554
min(all_train_mounds$elongtn) #1.058625
max(all_train_mounds$elongtn) #1.259723
min(all_train_mounds$cmpctns) #0.3097743
max(all_train_mounds$cmpctns) #0.3155191
