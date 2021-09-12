################################################################################
#######################THE WORKFLOW APPLIED ON THE TEST AREA####################
################################################################################
####--------------------------------SHORTCUTS-------------------------------####
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
trainarea05 <- raster(lstraintarea[[6]])
crs(trainarea05)
#CRS arguments: +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
mapview(trainarea05)
################################################################################
####-----------------------------#2. FILTER DTM#----------------------------####
#let's use a mean/low-pass filter with 3x3 moving window because we are looking
#for relatively delicate features
TAfDTM05<- filtR(trainarea05, filtRs="mean", sizes=3, NArm=TRUE)

names(TAfDTM05)
#"DTM2014_test_area_merged05_mean3"

names(TAfDTM05) <- "fDTM05"

#export filter
raster::writeRaster(TAfDTM05, paste0(path_analysis_results_6c_iSEG05_RG_ta,
                    "/TAfDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)

#read raster
TAfDTM05 <- raster::raster(paste0(path_analysis_results_6c_iSEG05_RG_ta, "TAfDTM05.tif"))
################################################################################
####------------------------#3.INVERT THE FILTERED DTMS#--------------------####
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
TAifDTM05 <- spatialEco::raster.invert(TAfDTM05)
raster::writeRaster(TAifDTM05, paste0(path_analysis_results_6c_iSEG05_RG_ta,
                    "/TAifDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)

#read inverse filtered DTM05
TAifDTM05 <- raster::raster(paste0(path_analysis_results_6c_iSEG05_RG_ta, "TAifDTM05.tif"))
################################################################################
####---------------------#4.PIT FILLING OF INVERSE FILTERED DTM#------------####
#Freeland et al. 2016 & Rom et al. use Wang and Liu 2006, which is implemented
#in Whitebox GAT & SAGA to make it simple we are going to use SAGA
#----------------------------------------SAGA----------------------------------#
#with a value of zero sinks are filled up to the spill elevation (which results in flat areas
#(from the module description)
####-----------------------#Fill Sinks (Wang & Liu 2006)#-------------------####
filled_DTM_SAGA_WL(dtm= TAifDTM05,
                   output= paste0(path_analysis_results_6c_iSEG05_RG_ta),
                   tmp= paste0(path_tmp),
                   minslope= 0,
                   crs= crs(trainarea05))
TApf_ifDTM_WL05 <- raster::raster(paste0(path_analysis_results_6c_iSEG05_RG_ta, "pf_ifDTM_W&L.tif"))
################################################################################
####-----------#5.SUBRATCTION OF INVERSE DTM FROM PIT-FILLED DTM#-----------####
TAdiff_ifDTM05 <- TAifDTM05 - TApf_ifDTM_WL05

raster::writeRaster(TAdiff_ifDTM05, paste0(path_analysis_results_6c_iSEG05_RG_ta,
                    "/TAdiff_ifDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####-------------------------#6.FILTER diff_ifDTM05##-----------------------####
##When checking in QGIS and making profiles along the barrows can see that there
#are a lot of small outliers which disturb when processing further
#let's use a 3x3 moving window with different filters: sum, min, max, mean,
#median, modal, sd, sobel and check in QGIS how well the barrows still are visible
TAfiltered_diff_ifDTM05<- filtR(TAdiff_ifDTM05, filtRs= c("all"), sizes=3, NArm=TRUE)

names(TAfiltered_diff_ifDTM05)

names(TAfiltered_diff_ifDTM05) <- c("TAfdiff_ifDTM05_sum3", "TAfdiff_ifDTM05_min3",
                                    "TAfdiff_ifDTM05_max3", "TAfdiff_ifDTM05_mean3",
                                    "TAfdiff_ifDTM05_median3", "TAfdiff_ifDTM05_modal3",
                                    "TAfdiff_ifDTM05_sd3", "TAfdiff_ifDTM05_sobel3")
#export filter one by one
writeRaster(TAfiltered_diff_ifDTM05, paste0(path_analysis_results_6c_iSEG05_RG_ta,
            filename = names(TAfiltered_diff_ifDTM05), ".tif"),
            format= "GTiff", bylayer = TRUE, overwrite=TRUE, NAflag = 0)

#After checking in QGIS it can be said that any filter which seems to be useful
#to enhance you OoI can be used in the next step. It was decided that the max
#filter restricts the non-mound areas the best way, but also it restricts the
#mounds in area but when using filters one has always to count in the loss of
#information to some extent
#################################################################################
####------------------#7. SEEDED REGION GROWING SEGMENTATIOM#---------------####
#--------------------#read the chosen filtered difference DTM#-----------------#
TAfdiff_ifDTM05_sd33 <- raster::raster(paste0(path_analysis_results_6c_iSEG05_RG_ta,
                       "/TAfdiff_ifDTM05_sum3.tif"))
#------------------------------#SEED GENERATION#-------------------------------#
#in the first step seeds are generated to be used in the actual segmentation
#NB. When using the segments from the WS segmentation the region growing does not work
#normalize, dw_weighting, dw_idw_power & dw_bandwidth are default values
generate_seedpoints_SAGA(dtm = TAfdiff_ifDTM05_sd3,
                         tmp = paste0(path_tmp),
                         seedtype = 1,
                         method = 1,
                         band_width = 100,
                         normalize=0,
                         dw_weighting = 1,
                         dw_idw_power=1,
                         dw_bandwidth=5,
                         crs = crs(trainarea05))
#-----------------------------#SEEDED REGION GROWING#--------------------------#
#The region growing algorithm needs seed generated by the seed generation tool
#in SAGA
#normalize, neighbour, sig_2 and leafsize are at default values
region_growing_SAGA(seeds=paste0(path_tmp, "/seedpoints.sgrd"),
                    dtm= TAfdiff_ifDTM05_sd3,
                    tmp=paste0(path_tmp),
                    output=paste0(path_analysis_results_6c_iSEG05_RG_ta),
                    normalize=0,
                    neighbour=0,
                    method=1,
                    sig_1=0.7,
                    sig_2=1,
                    threshold=0.5,
                    leafsize=256,
                    crs=crs(trainarea05))
#----------------------------POLYGONIZE RG SEGMENTS----------------------------#
#class_id & all_vertices are default value
polygonize_segments_SAGA(segments=paste0(path_tmp, "segments.sgrd"),
                         tmp=paste0(path_tmp),
                         class_all=1,
                         class_id=1,
                         split=1,
                         all_vertices=0)
################################################################################
####---------------------------#8.MANIPULATE SEGMENTS#----------------------####
segments<- readOGR(paste0(path_tmp, "segments.shp"))
crs(segments) <-crs(trainarea05)
mapview(segments)

#we can see that based on the method of region growing, all the raster is segmented
#check in mapview the ID +1 of the background segment!
#--------------------------#SUBTRACT BACKGROUND POLYGONS#----------------------#
#The ID of the big segments is: 348, 380, 1400, 1836, 1856, 1889, 2034, 2086, 2189, 2387, 3722,
segments_purged_RG_ta<- subset(segments, ID %in% c('0':'347', '349':'379',
                                                   '381':'1399', '1401':'1835',
                                                   '1837':'1855', '1857':'1888',
                                                   '1890':'2033', '2035':'2085',
                                                   '2087':'2188', '2190':'2386',
                                                   '2388':'3721',  '3723':'4273'))
mapview(segments_purged_RG_ta)
#---------------------------------#export segments#----------------------------#
rgdal::writeOGR(obj=segments_purged_RG_ta, dsn = "/home/keltoskytoi/repRCHrs/tmp",
                layer ="segments", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
####-------------------------#9.JOIN NEIGHBORING POLYGONS#------------------####
segments <- readOGR(paste0(path_tmp, "segments.shp"))
#The resulting segment are nested in each other thus these segments have to be
#joined together to be able to work with them
#the following code was adapted:
#https://gis.stackexchange.com/questions/79114/joining-nearest-neighbor-small-polygons-using-r

neighb <- spdep::poly2nb(segments)
region <- create_regions(neighb)
pol_rgn <- maptools::spCbind(segments, region)
segments <- maptools::unionSpatialPolygons(pol_rgn, region)
#SpP is invalid because there are self-intersections; but it still works
mapview::mapview(segments)
#---------------------#transform to a spatial polygons dataframe#--------------#
class(segments)
#"SpatialPolygons"
segments <- SpatialPolygonsDataFrame(segments, data.frame(id=1:length(segments)))
class(segments)
#"SpatialPolygonsDataFrame"
#------------------------#export the spatial polygons dataframe#---------------#
rgdal::writeOGR(obj=segments, dsn = "/home/keltoskytoi/repRCHrs/tmp",
                layer ="segments", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
####---------------------#10.COMPUTE SHAPE INDEX OF SEGMENTS#---------------####
compute_shape_index_SAGA(segments=paste0(path_tmp, "segments.shp"),
                         tmp=paste0(path_tmp),
                         index=paste0(path_tmp, "segments.shp"),
                         gyros=1,
                         feret=1,
                         feret_dirs=18)
################################################################################
#####------------#11.CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#------------####
#----------------------------#LOAD SHAPE FILES & PLOT THEM#--------------------#
segments_iSEG_RG_ta <- readOGR(paste0(path_tmp, "segments.shp"))
burial_mounds_5 <- readOGR(paste0(path_analysis_data_barrows, "5_Dobiat_1994.shp"))
burial_mounds_7 <- readOGR(paste0(path_analysis_data_barrows, "7_Dobiat_1994.shp"))
burial_mounds_14 <- readOGR(paste0(path_analysis_data_barrows, "14_Dobiat_1994.shp"))
burial_mounds_35 <- readOGR(paste0(path_analysis_data_barrows, "35_Dobiat_1994.shp"))
mapview::mapview(segments_iSEG_RG_ta) + burial_mounds_5 + burial_mounds_7 + burial_mounds_14 + burial_mounds_35
#it was already clear from the first plot of the segments that not all burial mounds
#will be describably by a segment
####--------------#calculate additional descriptive variables---------------####
segments_iSEG_RG_ta@data$compactness <- (sqrt(4*segments_iSEG_RG_ta@data$A/pi))/segments_iSEG_RG_ta@data$P
segments_iSEG_RG_ta@data$roundness <- (4*segments_iSEG_RG_ta@data$A)/(pi*segments_iSEG_RG_ta@data$Fmax)
segments_iSEG_RG_ta@data$elongation <- segments_iSEG_RG_ta@data$Fmax/segments_iSEG_RG_ta@data$Fmin

names(segments_iSEG_RG_ta)
#[1] "ID"          "A"           "P"           "P.A"         "P.sqrt.A."   "Depqc"
#[7] "Sphericity"  "Shape.Index" "Dmax"        "DmaxDir"     "Dmax.A"      "Dmax.sqrt.A"
#[13] "Dgyros"      "Fmax"        "FmaxDir"     "Fmin"        "FminDir"     "Fmean"
#[19] "Fmax90"      "Fmin90"      "Fvol"        "compactness"  "roundness"  "elongation"

#export the segments with the additional descriptive variables
rgdal::writeOGR(obj=segments_iSEG_RG_ta, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/6c_iSEG05_RG_ta",
                layer ="segments_purged_shape_descriptive_joined_RG_ta", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
#in case that you want to read the segments at a later point, you will have to
#change the column names:
#segments_iSEG_RG_ta <- readOGR(paste0(path_analysis_results_6c_iSEG05_RG_ta,
#                               "segments_purged_shape_descriptive_joined_RG_ta.shp"))
#names(segments_iSEG_RG_ta)
#[1] "ID"      "A"       "P"       "P_A"     "P_sq_A_" "Depqc"   "Sphrcty" "Shp_Ind"
#[9] "Dmax"    "DmaxDir" "Dmax_A"  "Dmx_s_A" "Dgyros"  "Fmax"    "FmaxDir" "Fmin"
#[17] "FminDir" "Fmean"   "Fmax90"  "Fmin90"  "Fvol"    "cmpctns" "rondnss" "elongtn"
####----------------#12. THRESHOLD BASED FILTERING OF SEGMENTS--------------####
#The most descriptive segment of the mound was selected as reference for area and
#sphericity
#NB: the Shape Index characterizes the deviation from an optimal circle. A Shape
#Index of 1.4 - 1.7 can be seen as relatively compact but of course it depends
#on the context

#We can say in general, that the segments do not really depict the mounds really
#accurately
#------------------------#Dobiat 1994, Grave group 5#--------------------------#
Mound_5_1 <- segments_iSEG_RG_ta[926,] #925+1
#Mound_5_2 <- segments_iSEG_RG_ta[,] #
Mound_5_3 <- segments_iSEG_RG_ta[845,] #844 +1
Mound_5_4 <- segments_iSEG_RG_ta[863,] #862+1
Mound_5_5 <- segments_iSEG_RG_ta[836,] #835+1 #### the inner circle was taken
Mound_5_6 <- segments_iSEG_RG_ta[869,] #868+1
Mound_5_7 <- segments_iSEG_RG_ta[925,] #924+1
Mound_5_8 <- segments_iSEG_RG_ta[966,] #965+1
Mound_5_9 <- segments_iSEG_RG_ta[781,] #780+1
#------------------------#Dobiat 1994, Grave group 7#--------------------------#
Mound_7_1 <- segments_iSEG_RG_ta[1284,] #1283+1 ####very elongated
Mound_7_2 <- segments_iSEG_RG_ta[1271,] #1270+1
Mound_7_3 <- segments_iSEG_RG_ta[1303,] #1302+1
#Mound_7_4 <- segments_iSEG_RG_ta[1340,] #1339+1 #### very small
#Mound_7_5 <- segments_iSEG_RG_ta[,] #
#Mound_7_6 <- segments_iSEG_RG_ta[1364,] #1363+1 #### very small
#Mound_7_7 <- segments_iSEG_RG_ta[,] #
Mound_7_8 <- segments_iSEG_RG_ta[1418,] #1417+1
#Mound_7_9 <- segments_iSEG_RG_ta[1420,] #1419+1 + the bigger of the two small segments was taken
#------------------------#Dobiat 1994, Grave group 14#--------------------------#
Mound_14_1 <- segments_iSEG_RG_ta[1924,] #1923+1 # the inner circle was chosen
Mound_14_2 <- segments_iSEG_RG_ta[2021,] #2020+1
#Mound_14_3 <- segments_iSEG_RG_ta[,] #
Mound_14_4 <- segments_iSEG_RG_ta[2370,] #2369+1
#Mound_14_5 <- segments_iSEG_RG_ta[2447,] #2446 #### very elongated
Mound_14_6 <- segments_iSEG_RG_ta[2471,] #2470 #### very small
Mound_14_7 <- segments_iSEG_RG_ta[2502,] #2501+1
#Mound_14_8 <- segments_iSEG_RG_ta[2500,] #2499+1 #### very elongated
Mound_14_9 <- segments_iSEG_RG_ta[2544,] #2543+1
Mound_14_10 <- segments_iSEG_RG_ta[2555,] #2554+1
Mound_14_11 <- segments_iSEG_RG_ta[2526,] #2525+1
Mound_14_12 <- segments_iSEG_RG_ta[2561,] #2560 +1
Mound_14_13 <- segments_iSEG_RG_ta[2598,] #2597+1
Mound_14_14 <- segments_iSEG_RG_ta[2622,] #2621+1
Mound_14_15 <- segments_iSEG_RG_ta[2646,] #2645+1
Mound_14_16 <- segments_iSEG_RG_ta[28,] #27+1
Mound_14_17 <- segments_iSEG_RG_ta[46,] #45+1 #### the bigger of the two small segments
Mound_14_18 <- segments_iSEG_RG_ta[93,] #92+1 ####very elongated - practically a ring
#Mound_14_19 <- segments_iSEG_RG_ta[,] #

#bind the reference segments together:
#minus a lot...

reference_descriptors_RG_ta <- bind(Mound_5_1, Mound_5_3, Mound_5_4,   Mound_5_5,
                                    Mound_5_6, Mound_5_7, Mound_5_8, Mound_5_9,
                                    Mound_7_1, Mound_7_2,   Mound_7_3,   Mound_7_8,
                                    Mound_14_1,  Mound_14_2,  Mound_14_4, Mound_14_6,
                                    Mound_14_7,  Mound_14_9,  Mound_14_10, Mound_14_11,
                                    Mound_14_12,  Mound_14_13, Mound_14_14, Mound_14_15,
                                    Mound_14_16,  Mound_14_17, Mound_14_18, Mound_14_19)

min(reference_descriptors_RG_ta$A) #9.75
max(reference_descriptors_RG_ta$A) #603
min(reference_descriptors_RG_ta$Sphericity) #0.4127783
max(reference_descriptors_RG_ta$Sphericity) #0.7921941
min(reference_descriptors_RG_ta$Shape.Index) #1.262317
max(reference_descriptors_RG_ta$Shape.Index) #2.422608
min(reference_descriptors_RG_ta$elongation) #1.109656
max(reference_descriptors_RG_ta$elongation) #2.319854
min(reference_descriptors_RG_ta$compactness) #0.1313914
max(reference_descriptors_RG_ta$compactness) #0.2521632

####---------------------------#MOUND THRESHOLDS#---------------------------####
#let's filter for segments of the area, sphericity, shape index, elongation
#and compactness

#based on the experciences it is best to aim below and above the respective thresholds to get all mounds
segments_iSEG_RG_ta_filt <- segments_iSEG_RG_ta[segments_iSEG_RG_ta$A <= 603.1 & segments_iSEG_RG_ta$A >= 9.7 &
                                                segments_iSEG_RG_ta$Sphericity >= 0.4127780 & segments_iSEG_RG_ta$Sphericity <= 0.7921950 &
                                                segments_iSEG_RG_ta$Shape.Index >= 1.262310 & segments_iSEG_RG_ta$Shape.Index <= 2.422610 &
                                                segments_iSEG_RG_ta$elongation >= 1.109650 & segments_iSEG_RG_ta$elongation <=2.319860 &
                                                segments_iSEG_RG_ta$compactness >= 0.1313910 & segments_iSEG_RG_ta$compactness <= 0.2521640,]
mapview::mapview(segments_iSEG_RG_ta_filt) + burial_mounds_5 + burial_mounds_7 + burial_mounds_14
#------------------------------------------------------------------------------#
rgdal::writeOGR(obj=segments_iSEG_RG_ta_filt, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/6c_iSEG05_RG_ta",
                layer ="iSEG_RG_ta", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
