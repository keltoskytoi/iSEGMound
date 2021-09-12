################################################################################
########################WORKFLOW DEVELOPED ON THE TESTDTM#######################
################################################################################
####------------------------------#SHORTCUTS#-------------------------------####
lstrainarea <-  list.files(file.path(path_analysis_results_train_area),
                          full.names = TRUE, pattern = glob2rx("*.tif"))
lstrainarea
#[1] "/home/keltoskytoi/repRCHrs/analysis/results/train_area//3dm_32482_5616_1_he_xyzirnc_ground_05.tif"
#[2] "/home/keltoskytoi/repRCHrs/analysis/results/train_area//3dm_32482_5617_1_he_xyzirnc_ground_05.tif"
#[3] "/home/keltoskytoi/repRCHrs/analysis/results/train_area//3dm_32482_5618_1_he_xyzirnc_ground_05.tif"
#[4] "/home/keltoskytoi/repRCHrs/analysis/results/train_area//3dm_32482_5619_1_he_xyzirnc_ground_05.tif"
#[5] "/home/keltoskytoi/repRCHrs/analysis/results/train_area//3dm_32483_5616_1_he_xyzirnc_ground_05.tif"
#[6] "/home/keltoskytoi/repRCHrs/analysis/results/train_area//test_area_xyzirnc_ground_05.tif"
################################################################################
####-----------------------------#1. READ DTM#------------------------------####
traindtm05 <- raster::raster(lstrainarea[[3]])
crs(traindtm05)
#CRS arguments: +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
mapview(traindtm05)
################################################################################
####-----------------------------#2. FILTER DTM#----------------------------####
#let's use a mean/low-pass filter with 3x3 moving window because we are looking
#for relatively delicate features
fDTM05<- filtR(traindtm05, filtRs="mean", sizes=3, NArm=TRUE)

names(fDTM05)
#"X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_05r_mean3"

#let's rename the layer to something shorter and more expressive
names(fDTM05) <- "fDTM05"

#export filtered raster
raster::writeRaster(fDTM05, paste0(path_analysis_results_5a_iSEG05_WS, "/fDTM05.tif"),
                    format= "GTiff", overwrite = TRUE, NAflag = 0)
#read filtered raster
fDTM05 <- raster::raster(paste0(path_analysis_results_5a_iSEG05_WS, "fDTM05.tif"))
################################################################################
####--------------------------#3.INVERT FILTERED DTM#-----------------------####
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
ifDTM05 <- spatialEco::raster.invert(fDTM05)
raster::writeRaster(ifDTM05, paste0(path_analysis_results_5a_iSEG05_WS,
                    "/ifDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)

#read the result of inverted filtered raster
ifDTM05 <- raster::raster(paste0(path_analysis_results_5a_iSEG05_WS, "ifDTM05.tif"))
################################################################################
####---------------------#4.PIT FILLING OF INVERSE FILTERED DTM#------------####
#Freeland et al. 2016 & Rom et al. use Wang and Liu 2006, which is implemented in Whitebox GAT & SAGA
#to make it simple we are going to use SAGA
#----------------------------------------SAGA----------------------------------#
#with a value of zero sinks are filled up to the spill elevation (which results
#in flat areas (from the module description)
####-----------------------#Fill Sinks (Wang & Liu 2006)#-------------------####
filled_DTM_SAGA_WL(dtm= ifDTM05,
                   output= file.path(path_analysis_results_5a_iSEG05_WS),
                   tmp= file.path(path_tmp),
                   minslope= 0,
                   crs=crs(traindtm05))

#read the result of the pit-filling
pf_ifDTM_WL05 <- raster::raster(paste0(path_analysis_results_5a_iSEG05_WS, "pf_ifDTM_W&L.tif"))
################################################################################
####-----------#5.SUBRATCTION OF INVERSE DTM FROM PIT-FILLED DTM#-----------####
#subtract inverse DTM from pit-filled DTM
diff_ifDTM05 <- ifDTM05 - pf_ifDTM_WL05

raster::writeRaster(diff_ifDTM05, paste0(path_analysis_results_5a_iSEG05_WS,
                    "/diff_ifDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####--------------------------#6.FILTER diff_ifDTM05#-----------------------####
#We can see that there still are a lot of small pixels which disturb when
#processing further diff_ifDTM05 further, so let's filter again.
#Let's use a 3x3 moving window with different filters: sum, min, max, mean,
#median, modal, sd, sobel and check in QGIS how well the barrows still are

filtered_diff_ifDTM05<- filtR(diff_ifDTM05, filtRs="all", sizes=3, NArm=TRUE)

names(filtered_diff_ifDTM05)
#[1] "layer_sum3"    "layer_min3"    "layer_max3"    "layer_mean3"   "layer_median3"
#[6] "layer_modal3"  "layer_sd3"     "layer_sobel3

names(filtered_diff_ifDTM05) <- c("fdiff_ifDTM05_sum3", "fdiff_ifDTM05_min3",
                                  "fdiff_ifDTM05_max3", "fdiff_ifDTM05_mean3",
                                  "fdiff_ifDTM05_median3", "fdiff_ifDTM05_modal3",
                                  "fdiff_ifDTM05_sd3", "fdiff_ifDTM05_sobel3")

#export filter
writeRaster(filtered_diff_ifDTM05, paste0(path_analysis_results_5a_iSEG05_WS,
            filename = names(filtered_diff_ifDTM05), ".tif"),
            format= "GTiff", bylayer = TRUE, overwrite=TRUE, NAflag = 0)
#After checking in QGIS it can be said that any filter which seems to be useful
#to enhance you OoI can be used in the next step. It was decided that the max
#filter restricts the non-mound areas the best way, and also the mounds in area
#but when using filters one has always to count in the loss of information to some extent
################################################################################
####------------------------#7.WATERSHED SEGMENTATION#----------------------####
#First choose a filtered diff_ifDTM05 which characterizes the OoI the best way
fdiff_ifDTM05_modal3 <- raster::raster(paste0(path_analysis_results_5a_iSEG05_WS, "fdiff_ifDTM05_modal3.tif"))

watershed_SAGA(dtm=fdiff_ifDTM05_modal3,
               output= paste0(path_analysis_results_5a_iSEG05_WS),
               tmp= paste0(path_tmp),
               output_choice=0,
               down=1,
               join=1,
               threshold=0.5,
               edge=0,
               borders=0,
               crs=crs(traindtm05))
####--------------------------#POLYGONIZE WS SEGMENTS#----------------------####
polygonize_segments_SAGA(segments=paste0(path_tmp, "segments.sgrd"),
                         tmp=paste0(path_tmp),
                         class_all=1,
                         class_id=1,
                         split=1,
                         all_vertices=0)
################################################################################
####-------------------------#8.JOIN NEIGHBORING POLYGONS#------------------####
#read segments and plot them together with the burial mounds
segments <- readOGR(paste0(path_tmp, "segments.shp"))
burial_mounds_5 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994.shp"))
#assign projection to the segments
crs(segments) <- crs(burial_mounds_5)
mapview::mapview(segments) + burial_mounds_5

#It is visible that there are many nested segments which might have the form and
#area of the burial mound segments AND the burial mounds are divided into multiple
#neighboring segments, thus these segments have to be joined together
#the following code was adapted:
#https://gis.stackexchange.com/questions/79114/joining-nearest-neighbor-small-polygons-using-r

neighb <- poly2nb(segments)
region <- create_regions(neighb)
pol_rgn <- spCbind(segments, region)
segments <- unionSpatialPolygons(pol_rgn, region)
#SpP is invalid because there are self-intersections; but it still works
mapview::mapview(segments)
#---------------------#transform to a spatial polygons dataframe#--------------#
#to be able to export the segments as .shp we have to transform then into a spatial
#polygons dataframe

#check class of polygons
class(segments)
#"SpatialPolygons"

#transform polygons
segments <- SpatialPolygonsDataFrame(segments, data.frame(id=1:length(segments)))
class(segments)
#"SpatialPolygonsDataFrame"
#------------------------#export the spatial polygons dataframe#---------------#
rgdal::writeOGR(obj=segments, dsn = "/home/keltoskytoi/repRCHrs/tmp",
                layer ="segments", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
####----------------------#9.COMPUTE SHAPE INDEX SEGMENTS#-----------------####
compute_shape_index_SAGA(segments=paste0(path_tmp, "segments.shp"),
                         tmp=paste0(path_tmp),
                         index=paste0(path_tmp, "segments.shp"),
                         gyros=1,
                         feret=1,
                         feret_dirs=18)
################################################################################
####------------#10.CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#-------------####
#----------------------------#LOAD SHAPE FILES & PLOT THEM#--------------------#
segments_iSEG_WS <- readOGR(paste0(path_tmp, "segments.shp"))
mapview::mapview(segments_iSEG_WS) + burial_mounds_5
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments_iSEG_WS@data$compactness <- (sqrt(4*segments_iSEG_WS@data$A/pi))/segments_iSEG_WS@data$P
segments_iSEG_WS@data$roundness <- (4*segments_iSEG_WS@data$A)/(pi*segments_iSEG_WS@data$Fmax)
segments_iSEG_WS@data$elongation <- segments_iSEG_WS@data$Fmax/segments_iSEG_WS@data$Fmin

names(segments_iSEG_WS)
#[1] "ID"          "A"           "P"           "P.A"         "P.sqrt.A."
#[6] "Depqc"       "Sphericity"  "Shape.Index" "Dmax"        "DmaxDir"
#[11] "Dmax.A"      "Dmax.sqrt.A" "Dgyros"      "Fmax"        "FmaxDir"
#[16] "Fmin"        "FminDir"     "Fmean"       "Fmax90"      "Fmin90"
#[21] "Fvol"        "compactness" "roundness"   "elongation"

#export the segments with the additional descriptive variables
rgdal::writeOGR(obj=segments_iSEG_WS, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/5a_iSEG05_WS",
                layer ="segments_shape_descriptive_joined_WS", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
#in case that you want to read the segments at a later point, you will have to
#change the column names:
#segments_iSEG_WS <- readOGR(paste0(path_analysis_results_5a_iSEG05_WS,
#                            "segments_shape_descriptive_joined_WS.shp"))
#names(segments_iSEG_WS)
#[1] "ID"      "A"       "P"       "P_A"     "P_sq_A_" "Depqc"   "Sphrcty" "Shp_Ind"
#[9] "Dmax"    "DmaxDir" "Dmax_A"  "Dmx_s_A" "Dgyros"  "Fmax"    "FmaxDir" "Fmin"
#[17] "FminDir" "Fmean"   "Fmax90"  "Fmin90"  "Fvol"    "cmpctns" "rondnss" "elongtn"
################################################################################
####----------------#11. THRESHOLD BASED FILTERING OF SEGMENTS--------------####
#The most descriptive segment of the mound was selected as reference for area and
#sphericity
#NB: the Shape Index characterizes the deviation from an optimal circle. A Shape
#Index of 1.4 - 1.7 can be seen as relatively compact but of course it depends
#on the context
#------------------basic descriptive values of burial_mounds_9-----------------#
#keep in mind, that you need to call ID+1!
#### denominates burial mound segments with amorph structure
#------------------------#Dobiat 1994, Grave group 9#--------------------------#
Mound_5_1 <- segments_iSEG_WS[1356,] #1355+1
Mound_5_2 <- segments_iSEG_WS[1209,] #1208+1
Mound_5_3 <- segments_iSEG_WS[967,] #966+1
Mound_5_4 <- segments_iSEG_WS[1072,] #1071+1
Mound_5_5 <- segments_iSEG_WS[933,] #932+1
Mound_5_6 <- segments_iSEG_WS[1036,] #1035+1 #### is amorph and a lot bigger
Mound_5_7 <- segments_iSEG_WS[1367,] #1366+1
Mound_5_8 <- segments_iSEG_WS[1573,] #1572+1
Mound_5_9 <- segments_iSEG_WS[627,] #626+1

reference_descriptors_WS <- bind(Mound_5_1, Mound_5_2, Mound_5_3, Mound_5_4, Mound_5_5,
                                 Mound_5_6, Mound_5_7, Mound_5_8, Mound_5_9)

min(reference_descriptors_WS$A) #32.25
max(reference_descriptors_WS$A) #651.75
min(reference_descriptors_WS$Sphericity) #0.5641041
max(reference_descriptors_WS$Sphericity) #0.8052482
min(reference_descriptors_WS$Shape.Index) #1.241853
max(reference_descriptors_WS$Shape.Index) #1.772722
min(reference_descriptors_WS$elongation) #1.092161
max(reference_descriptors_WS$elongation) #1.576406
min(reference_descriptors_WS$compactness) #0.1795599
max(reference_descriptors_WS$compactness) #0.2563185

####---------------------------#MOUND THRESHOLDS#---------------------------####
#let's filter for segments of the area, sphericity, shape index, elongation
#and compactness
#based on the experiences it is best to aim below and above the respective thresholds to get all mounds
iSEG_WS_filt <- segments_iSEG_WS[segments_iSEG_WS$A <= 651.80 & segments_iSEG_WS$A >= 32.20 &
                                 segments_iSEG_WS$Sphericity >= 0.5641040 & segments_iSEG_WS$Sphericity <= 0.8052485 &
                                 segments_iSEG_WS$Shape.Index >= 1.241850 & segments_iSEG_WS$Shape.Index <= 1.772725 &
                                 segments_iSEG_WS$elongation >= 1.092160 & segments_iSEG_WS$elongation <= 1.576410 &
                                 segments_iSEG_WS$compactness >= 0.1795598 & segments_iSEG_WS$compactness <= 0.2563190,]
mapview::mapview(iSEG_WS_filt) + burial_mounds_5
#-----------------------------#EXPORT FILTERED MOUNDS#-------------------------#
rgdal::writeOGR(obj=iSEG_WS_filt, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/5a_iSEG05_WS",
                layer ="iSEG_WS", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
