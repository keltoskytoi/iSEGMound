################################################################################
###########################WORKFLOW APPLIED ON THE TEST AREA####################
################################################################################
####--------------------------------#SHORTCUTS#-----------------------------####
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
trainarea05 <- raster(lstrainarea[[6]])
crs(trainarea05)
#CRS arguments: +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
mapview(trainarea05)
################################################################################
####-----------------------------#2. FILTER DTM#----------------------------####
#let's use a mean/low-pass filter with 3x3 moving window because we are looking
#for relatively delicate features
TAfDTM05<- filtR(trainarea05, filtRs="mean", sizes=3, NArm=TRUE)

names(TAfDTM05)
#"test_area_xyzirnc_ground_05_mean3""

##let's rename the layer to something shorter and more expressive
names(TAfDTM05) <- "TAfDTM05"

#export filter
raster::writeRaster(TAfDTM05, paste0(path_analysis_results_6a_iSEG05_WS_ta,
                    "/TAfDTM05.tif"), format= "GTiff", overwrite=TRUE, NAflag = 0)

#read raster
TAfDTM05 <- raster::raster(paste0(path_analysis_results_6a_iSEG05_WS_ta, "TAfDTM05.tif"))
################################################################################
####--------------------------#3.INVERT FILTERED DTM#-----------------------####
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
TAifDTM05 <- spatialEco::raster.invert(TAfDTM05)
raster::writeRaster(TAifDTM05, paste0(path_analysis_results_6a_iSEG05_WS_ta,
                    "/TAifDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)

#read the result of inverted filtered raster
TAifDTM05 <- raster::raster(paste0(path_analysis_results_6a_iSEG05_WS_ta, "TAifDTM05.tif"))
################################################################################
####---------------------#4.PIT FILLING OF INVERSE FILTERED DTM#------------####
#Freeland et al. 2016 & Rom et al. use Wang and Liu 2006, which is implemented in Whitebox GAT & SAGA
#to make it simple we are going to use SAGA
#----------------------------------------SAGA----------------------------------#
#with a value of zero sinks are filled up to the spill elevation (which results in flat areas
#(from the module description)

####-----------------------#Fill Sinks (Wang & Liu 2006)#-------------------####
filled_DTM_SAGA_WL(dtm= TAifDTM05,
                   output= paste0(path_analysis_results_6a_iSEG05_WS_ta),
                   tmp= paste0(path_tmp),
                   minslope= 0,
                   crs= crs(trainarea05))

#read the result of the pit-filling
TApf_ifDTM_WL05 <- raster::raster(paste0(path_analysis_results_6a_iSEG05_WS_ta, "pf_ifDTM_W&L.tif"))
################################################################################
####-----------#5.SUBRATCTION OF INVERSE DTM FROM PIT-FILLED DTM#-----------####
#subtract inverse DTM from pit-filled DTM
TAdiff_ifDTM05 <- TAifDTM05 - TApf_ifDTM_WL05

raster::writeRaster(TAdiff_ifDTM05, paste0(path_analysis_results_6a_iSEG05_WS_ta,
                    "/TAdiff_ifDTM05.tif"), format= "GTiff", overwrite=TRUE, NAflag = 0)
################################################################################
####--------------------------#6.FILTER diff_ifDTM05#-----------------------####
#We can see that there are a lot of small pixels which disturb when processing further
#let's use a 3x3 moving window with different filters: sum, min, max, mean,
#median, modal, sd, sobel and check in QGIS how well the barrows still are

TAfiltered_diff_ifDTM05<- filtR(TAdiff_ifDTM05, filtRs="all", size=3, NArm=TRUE)

names(TAfiltered_diff_ifDTM05)
#[1] "layer_sum3"    "layer_min3"    "layer_max3"    "layer_mean3"   "layer_median3"
#[6] "layer_modal3"  "layer_sd3"     "layer_sobel3"

names(TAfiltered_diff_ifDTM05) <- c("TAfdiff_ifDTM05_sum3", "TAfdiff_ifDTM05_min3",
                                    "TAfdiff_ifDTM05_max3", "TAfdiff_ifDTM05_mean3",
                                    "TAfdiff_ifDTM05_median3", "TAfdiff_ifDTM05_modal3",
                                    "TAfdiff_ifDTM05_sd3", "TAfdiff_ifDTM05_sobel3")

#export filter
writeRaster(TAfiltered_diff_ifDTM05, paste0(path_analysis_results_6a_iSEG05_WS_ta,
            filename = names(TAfiltered_diff_ifDTM05), ".tif"),
            format= "GTiff", bylayer = TRUE, overwrite=TRUE, NAflag = 0)

################################################################################
####------------------------#7.WATERSHED SEGMENTATION#----------------------####
#First choose a filtered diff_ifDTM05 which characterizes the OoI the best way
TAfdiff_ifDTM05_modal3 <- raster::raster(paste0(path_analysis_results_6a_iSEG05_WS_ta, "TAfdiff_ifDTM05_modal3.tif"))

watershed_SAGA(dtm=TAfdiff_ifDTM05_modal3,
               output= paste0(path_analysis_results_6a_iSEG05_WS_ta),
               tmp= paste0(path_tmp),
               output_choice=0,
               down=1,
               join=1,
               threshold=0.5,
               edge=0,
               borders=0,
               crs=crs(trainarea05))
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
segments_iSEG_WS_ta <- readOGR(paste0(path_tmp, "segments.shp"))
burial_mounds_5 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994.shp"))
burial_mounds_7 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "7_Dobiat_1994.shp"))
burial_mounds_14 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "14_Dobiat_1994.shp"))
burial_mounds_35 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994.shp"))
mapview::mapview(segments_iSEG_WS_ta) + burial_mounds_5 + burial_mounds_7 + burial_mounds_14 + burial_mounds_35
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments_iSEG_WS_ta@data$compactness <- (sqrt(4*segments_iSEG_WS_ta@data$A/pi))/segments_iSEG_WS_ta@data$P
segments_iSEG_WS_ta@data$roundness <- (4*segments_iSEG_WS_ta@data$A)/(pi*segments_iSEG_WS_ta@data$Fmax)
segments_iSEG_WS_ta@data$elongation <- segments_iSEG_WS_ta@data$Fmax/segments_iSEG_WS_ta@data$Fmin

names(segments_iSEG_WS_ta)
#[1] "ID"          "A"           "P"           "P.A"         "P.sqrt.A."
#[6] "Depqc"       "Sphericity"  "Shape.Index" "Dmax"        "DmaxDir"
#[11] "Dmax.A"      "Dmax.sqrt.A" "Dgyros"      "Fmax"        "FmaxDir"
#[16] "Fmin"        "FminDir"     "Fmean"       "Fmax90"      "Fmin90"
#[21] "Fvol"        "compactness" "roundness"   "elongation"
#------------------------------------------------------------------------------#
#export the segments with the additional descriptive variables
rgdal::writeOGR(obj=segments_iSEG_WS_ta, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/6a_iSEG05_WS_ta",
                layer ="segments_shape_descriptive_joined_WS_ta", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
#in case that you want to read the segments at a later point, you will have to
#change the column names:
#segments_iSEG_WS_ta <- readOGR(paste0(path_analysis_results_8a_iSEG05_WS_ta
#                             "segments_shape_descriptive_joined_WS_ta.shp"))
#names(segments_iSEG_WS_ta)
#[1] "ID"      "A"       "P"       "P_A"     "P_sq_A_" "Depqc"   "Sphrcty" "Shp_Ind"
#[9] "Dmax"    "DmaxDir" "Dmax_A"  "Dmx_s_A" "Dgyros"  "Fmax"    "FmaxDir" "Fmin"
#[17] "FminDir" "Fmean"   "Fmax90"  "Fmin90"  "Fvol"    "cmpctns" "rondnss" "elongtn"

####----------------#11. THRESHOLD BASED FILTERING OF SEGMENTS--------------####
#The most descriptive segment of the mound was selected as reference for area and
#sphericity
#NB: the Shape Index characterizes the deviation from an optimal circle. A Shape
#Index of 1.4 - 1.7 can be seen as relatively compact but of course it depends
#on the context
#------------------basic descriptive values of the burial mounds---------------#
#keep in mind, that you need to call ID+1!
#### denominates burial mound segments with amorph stucture
#------------------------#Dobiat 1994, Grave group 5#--------------------------#
Mound_5_1 <- segments_iSEG_WS_ta[13766,] #13765+1
Mound_5_2 <- segments_iSEG_WS_ta[13619,] #13618+1
Mound_5_3 <- segments_iSEG_WS_ta[13378,] #13377+1
Mound_5_4 <- segments_iSEG_WS_ta[13481,] #13480+1
Mound_5_5 <- segments_iSEG_WS_ta[13344,] #13343+1
Mound_5_6 <- segments_iSEG_WS_ta[13447,] #13446+1 #### is amorph and a lot bigger
Mound_5_7 <- segments_iSEG_WS_ta[13777,] #13776+1
Mound_5_8 <- segments_iSEG_WS_ta[13988,] #13987+1
Mound_5_9 <- segments_iSEG_WS_ta[13040,] #13039+1
#------------------------#Dobiat 1994, Grave group 7#--------------------------#
Mound_7_1 <- segments_iSEG_WS_ta[1334,] #1333+1
Mound_7_2 <- segments_iSEG_WS_ta[1246,] #1245+1
Mound_7_3 <- segments_iSEG_WS_ta[1413,] #1412+1
Mound_7_4 <- segments_iSEG_WS_ta[1567,] #1566+1 #### has an elongated tail
#Mound_7_5 <- segments_iSEG_WS_ta[1689,] #1688+1 #### 1 small segment
#Mound_7_6 <- segments_iSEG_WS_ta[1662,] #1661+1 #### taken the biggest of the 2 very small segments
#Mound_7_7 <- segments_iSEG_WS_ta[1788,] #1787+1 #### 1 even smaller segment
Mound_7_8 <- segments_iSEG_WS_ta[1843,] #1842+1
#Mound_7_9 <- segments_iSEG_WS_ta[1840,] #1839+1 #### small segments
#------------------------#Dobiat 1994, Grave group 14#--------------------------#
Mound_14_1 <- segments_iSEG_WS_ta[4169,] #4168+1
Mound_14_2 <- segments_iSEG_WS_ta[4938,] #4937+1
#Mound_14_3 <- segments_iSEG_WS_ta[3636,] #3635+1 ####only 5 pixels in area
Mound_14_4 <- segments_iSEG_WS_ta[6502,] #6501+1
Mound_14_5 <- segments_iSEG_WS_ta[6822,] #6821+1
#Mound_14_6 <- segments_iSEG_WS_ta[6893,] #6892+1 ####two segments, the rounder was used
Mound_14_7 <- segments_iSEG_WS_ta[7104,] #7103+1
Mound_14_8 <- segments_iSEG_WS_ta[7014,] #7013+1
Mound_14_9 <- segments_iSEG_WS_ta[7385,] #7384+1
Mound_14_10 <-segments_iSEG_WS_ta[7458,] #7457+1
Mound_14_11 <- segments_iSEG_WS_ta[7238,] #7237+1 #### has a tail
Mound_14_12 <- segments_iSEG_WS_ta[7540,] #7539+1
Mound_14_13 <- segments_iSEG_WS_ta[7722,] #7721+1
Mound_14_14 <- segments_iSEG_WS_ta[7837,] #7836+1
Mound_14_15 <- segments_iSEG_WS_ta[7972,] #7971+1 #### has a tail
Mound_14_16 <- segments_iSEG_WS_ta[8916,] #8915+1
Mound_14_17 <- segments_iSEG_WS_ta[9056,] #9055+1
Mound_14_18 <- segments_iSEG_WS_ta[9260,] #9259+1
Mound_14_19 <- segments_iSEG_WS_ta[7387,] #7386+1

#it is visible that Mound_35 is not

#bind the reference segments together:
#minus Mound_7_5, Mound_7_6, Mound_7_7, Mound_7_9, Mound_14_3 & Mound_14_6 because
#their area is small
reference_descriptors_WS_ta <- bind(Mound_5_1, Mound_5_2, Mound_5_3, Mound_5_4,
                                    Mound_5_5, Mound_5_6, Mound_5_7, Mound_5_8,
                                    Mound_5_9, Mound_7_1, Mound_7_2, Mound_7_3,
                                    Mound_7_4, Mound_7_8, Mound_14_1,  Mound_14_2,
                                    Mound_14_4,  Mound_14_5,  Mound_14_7,  Mound_14_8,
                                    Mound_14_9,  Mound_14_10, Mound_14_11, Mound_14_12,
                                    Mound_14_13, Mound_14_14, Mound_14_15, Mound_14_16,
                                    Mound_14_17, Mound_14_18, Mound_14_19)

min(reference_descriptors_WS_ta$A) #17.5
max(reference_descriptors_WS_ta$A) #652.25
min(reference_descriptors_WS_ta$Sphericity) #0.5149276
max(reference_descriptors_WS_ta$Sphericity) #0.8343847
min(reference_descriptors_WS_ta$Shape.Index) #1.198488
max(reference_descriptors_WS_ta$Shape.Index) #1.942021
min(reference_descriptors_WS_ta$elongation) #1.09425
max(reference_descriptors_WS_ta$elongation) #1.697496
min(reference_descriptors_WS_ta$compactness) #0.1639065
max(reference_descriptors_WS_ta$compactness) #0.2655929

####---------------------------#MOUND THRESHOLDS#---------------------------####
#let's filter for segments of the area, sphericity, shape index, elongation
#and compactness

#based on the experiences it is best to aim below and above the respective thresholds to get all mounds
segments_iSEG_WS_ta_filt <-segments_iSEG_WS_ta[segments_iSEG_WS_ta$A <= 652.3 & segments_iSEG_WS_ta$A >= 17.4 &
                                               segments_iSEG_WS_ta$Sphericity >=0.5149270 & segments_iSEG_WS_ta$Sphericity <= 0.8343850 &
                                               segments_iSEG_WS_ta$Shape.Index >=.198490 & segments_iSEG_WS_ta$Shape.Index <= 1.942022 &
                                               segments_iSEG_WS_ta$elongation >=1.09420 & segments_iSEG_WS_ta$elongation <= 1.697500 &
                                               segments_iSEG_WS_ta$compactness >= 0.1639060 & segments_iSEG_WS_ta$compactness <= 0.2655930,]
mapview::mapview(segments_iSEG_WS_ta_filt) + burial_mounds_5 + burial_mounds_7 + burial_mounds_14 + burial_mounds_35
#-----------------------------#EXPORT FILTERED MOUNDS#-------------------------#
rgdal::writeOGR(obj=segments_iSEG_WS_ta_filt, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/6a_iSEG05_WS_ta",
                layer ="iSEG_WS_ta", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
