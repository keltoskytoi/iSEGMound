################################################################################
####-------------#1.READ MOUNDS DOBIAT 1994 IN THE TRAIN AREA#---------------####
burial_mounds_5 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994.shp"))
burial_mounds_7 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "7_Dobiat_1994.shp"))
burial_mounds_9 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "9_Dobiat_1994.shp"))
burial_mounds_14 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "14_Dobiat_1994.shp"))
burial_mounds_35 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994.shp"))
burial_mounds_35_2 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_2_Dobiat_1994.shp"))
################################################################################
####-------------------------#MOUND GROUP 5#----------------------------####
rgdal::writeOGR(obj=burial_mounds_5, dsn = "C:/Users/kelto/Documents/iSEGMound/tmp",
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
segments$ID <- c(1:9)
segments$ID
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments@data$compactness <- (sqrt(4*segments@data$A/pi))/segments@data$P
segments@data$roundness <- (4*segments@data$A)/(pi*segments@data$Fmax)
segments@data$elongation <- segments@data$Fmax/segments@data$Fmin
#---------------------#EXPORT TRAIN SEGMENTS WITH DESCRIPTORS#-----------------#
rgdal::writeOGR(obj=segments, dsn = "C:/Users/kelto/Documents/iSEGMound/analysis/data/burial_mounds_Dobiat_1994",
                layer ="5_Dobiat_1994_SHI", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
mounds_5_SHI <-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994_SHI.shp"))
mapview(mounds_5_SHI)
#####-----------------------#REFERENCE DESCRIPTORS USED#--------------------####
min(mounds_5_SHI$A) #74.08783
max(mounds_5_SHI$A) #793.202
min(mounds_5_SHI$Sphrcty) #0.976802
max(mounds_5_SHI$Sphrcty) #0.9912325
min(mounds_5_SHI$Shp_Ind) #1.008845
max(mounds_5_SHI$Shp_Ind) #1.023749
min(mounds_5_SHI$elongtn) #1.058743
max(mounds_5_SHI$elongtn) #1.166369
min(mounds_5_SHI$cmpctns) #0.3109257
max(mounds_5_SHI$cmpctns) #0.3155191
################################################################################
####-------------------------#MOUND GROUPS 7#----------------------------####
mapview::mapview(burial_mounds_7)
#NOTE: that the mvFeaturesIDs of 7-2 and 7-3 got mixed up - no idea how to change the
#mvFeatureId, so I changed the ID. Would give problems later - just keep in mind the mixup
#set ID and mvFeatureID to the same value
burial_mounds_7$id <- 1:9
rgdal::writeOGR(obj=burial_mounds_7, dsn = "C:/Users/kelto/Documents/iSEGMound/tmp",
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
segments$ID <- c(1:9)
segments$ID
mapview(segments)
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments@data$compactness <- (sqrt(4*segments@data$A/pi))/segments@data$P
segments@data$roundness <- (4*segments@data$A)/(pi*segments@data$Fmax)
segments@data$elongation <- segments@data$Fmax/segments@data$Fmin
#---------------------#EXPORT TRAIN SEGMENTS WITH DESCRIPTORS#-----------------#
rgdal::writeOGR(obj=segments, dsn = "C:/Users/kelto/Documents/iSEGMound/analysis/data/burial_mounds_Dobiat_1994",
                layer ="7_Dobiat_1994_SHI", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
mounds_7_SHI <-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "7_Dobiat_1994_SHI.shp"))
mapview(mounds_7_SHI)
#####-----------------------#REFERENCE DESCRIPTORS USED#--------------------####
min(mounds_7_SHI$A) #78.92579
max(mounds_7_SHI$A) #182.4316
min(mounds_7_SHI$Sphrcty) #0.9783949
max(mounds_7_SHI$Sphrcty) #0.9896434
min(mounds_7_SHI$Shp_Ind) #1.010465
max(mounds_7_SHI$Shp_Ind) #1.022082
min(mounds_7_SHI$elongtn) #1.058625
max(mounds_7_SHI$elongtn) #1.204668
min(mounds_7_SHI$cmpctns) #0.3114328
max(mounds_7_SHI$cmpctns) #0.3150133
################################################################################
####-------------------------#MOUND GROUPS 9#----------------------------####
rgdal::writeOGR(obj=burial_mounds_9, dsn = "C:/Users/kelto/Documents/iSEGMound/tmp",
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
segments$ID <- 1
segments$ID
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments@data$compactness <- (sqrt(4*segments@data$A/pi))/segments@data$P
segments@data$roundness <- (4*segments@data$A)/(pi*segments@data$Fmax)
segments@data$elongation <- segments@data$Fmax/segments@data$Fmin
#---------------------#EXPORT TRAIN SEGMENTS WITH DESCRIPTORS#-----------------#
rgdal::writeOGR(obj=segments, dsn = "C:/Users/kelto/Documents/iSEGMound/analysis/data/burial_mounds_Dobiat_1994",
                layer ="9_Dobiat_1994_SHI", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
mounds_9_SHI <-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "9_Dobiat_1994_SHI.shp"))
mapview(mounds_9_SHI)
#####-----------------------#REFERENCE DESCRIPTORS USED#--------------------####
mounds_9_SHI$A #77.29794
mounds_9_SHI$Sphrcty #0.9839507
mounds_9_SHI$Shp_Ind #1.016311
mounds_9_SHI$elongtn #1.120807
mounds_9_SHI$cmpctns #0.3132012
################################################################################
####-------------------------#MOUND GROUPS 14#----------------------------####
rgdal::writeOGR(obj=burial_mounds_14, dsn = "C:/Users/kelto/Documents/iSEGMound/tmp",
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
segments$ID <- c(1:19)
segments$ID
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments@data$compactness <- (sqrt(4*segments@data$A/pi))/segments@data$P
segments@data$roundness <- (4*segments@data$A)/(pi*segments@data$Fmax)
segments@data$elongation <- segments@data$Fmax/segments@data$Fmin
#---------------------#EXPORT TRAIN SEGMENTS WITH DESCRIPTORS#-----------------#
rgdal::writeOGR(obj=segments, dsn = "C:/Users/kelto/Documents/iSEGMound/analysis/data/burial_mounds_Dobiat_1994",
                layer ="14_Dobiat_1994_SHI", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
mounds_14_SHI <-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "14_Dobiat_1994_SHI.shp"))
mapview(mounds_14_SHI)
#####-----------------------#REFERENCE DESCRIPTORS USED#--------------------####
min(mounds_14_SHI$A) #77.45146
max(mounds_14_SHI$A) #494.2297
min(mounds_14_SHI$Sphrcty) #0.9731846
max(mounds_14_SHI$Sphrcty) #0.9896421
min(mounds_14_SHI$Shp_Ind) #1.010466
max(mounds_14_SHI$Shp_Ind) #1.027554
min(mounds_14_SHI$elongtn) #1.071617
max(mounds_14_SHI$elongtn) #1.259723
min(mounds_14_SHI$cmpctns) #0.3097743
max(mounds_14_SHI$cmpctns) #0.3150129
################################################################################
####-------------------------#MOUND GROUPS 35#----------------------------####
burial_mounds_35_12 <- bind(burial_mounds_35, burial_mounds_35_2)
mapview(burial_mounds_35_12)
rgdal::writeOGR(obj=burial_mounds_35_12, dsn = "C:/Users/kelto/Documents/iSEGMound/tmp",
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
segments$ID <- c(1:2)
segments$ID
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments@data$compactness <- (sqrt(4*segments@data$A/pi))/segments@data$P
segments@data$roundness <- (4*segments@data$A)/(pi*segments@data$Fmax)
segments@data$elongation <- segments@data$Fmax/segments@data$Fmin
#---------------------#EXPORT TRAIN SEGMENTS WITH DESCRIPTORS#-----------------#
rgdal::writeOGR(obj=segments, dsn = "C:/Users/kelto/Documents/iSEGMound/analysis/data/burial_mounds_Dobiat_1994",
                layer ="35_Dobiat_1994_SHI", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
mounds_35_SHI <-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994_SHI.shp"))
mapview(mounds_35_SHI)
#####-----------------------#REFERENCE DESCRIPTORS USED#--------------------####
min(mounds_35_SHI$A) #239.3889
max(mounds_35_SHI$A) #253.7707
min(mounds_35_SHI$Sphrcty) #0.9747955
max(mounds_35_SHI$Sphrcty) #0.9856224
min(mounds_35_SHI$Shp_Ind) #1.014587
max(mounds_35_SHI$Shp_Ind) #1.025856
min(mounds_35_SHI$elongtn) #1.157296
max(mounds_35_SHI$elongtn) #1.200961
min(mounds_35_SHI$cmpctns) #0.3102871
max(mounds_35_SHI$cmpctns) #0.3137333
################################################################################
####-------------------------#ALL TRAIN MOUNDS#------------------------------####
all_train_mounds <- bind(mounds_5_SHI, mounds_7_SHI, mounds_9_SHI,
                         mounds_14_SHI, mounds_35_SHI)
mapview(all_train_mounds)

rgdal::writeOGR(obj=all_train_mounds, dsn = "C:/Users/kelto/Documents/iSEGMound/analysis/data/burial_mounds_Dobiat_1994",
                layer ="all_train_mounds", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)


