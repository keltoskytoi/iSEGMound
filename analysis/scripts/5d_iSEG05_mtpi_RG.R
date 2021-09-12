################################################################################
########################WORKFLOW DEVELOPED ON THE TESTDTM#######################
################################################################################
####-----------------------------#SHORTCUTS#--------------------------------####
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
####------------------------------#1. READ DTM#-----------------------------####
traindtm05 <- raster::raster(lstrainarea[[3]])
crs(traindtm05)
#CRS arguments: +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
mapview(traindtm05)
################################################################################
####--------------------------#2. CREATE A DERIVATIVE#----------------------####
#-----------------write testdtm as a SAGA grid into the tmp folder-------------#
raster::writeRaster(traindtm05, paste0(path_tmp,"/testdtm05.sdat"),
                    overwrite = TRUE, NAflag = 0)
#We understood from creating derivatives, that the multiscale topographic position
#index is very useful to enhance the flatly preserved burial mounds; so we will use
#MTPI before a filter
####------------------MULTISCALE TOPOGRAPHIC POSITION INDEX-----------------####
dDTM05_mtpid <- generate_mtpi_SAGA(dtm=traindtm05,
                                   output= paste0(path_analysis_results_5d_iSEG05_mtpi_RG),
                                   tmp= paste0(path_tmp),
                                   scale_min=1,
                                   scale_max=30,
                                   scale_num=2,
                                   crs=crs(traindtm05))
#read mtpi
dDTM05 <- raster::raster(paste0(path_analysis_results_5d_iSEG05_mtpi_RG, "dDTM05.tif"))
################################################################################
####--------------------------#3. FILTER DERIVATIVE#------------------------####
#let's use a mean/low-pass filter with 3x3 moving window because we are looking
#for relatively delicate features
fdDTM05<- filtR(dDTM05, filtRs="mean", sizes=3, NArm=TRUE)

#check the name of the layer
names(fdDTM05)
#[1] "dDTM05_mean3"

#export filtered raster
raster::writeRaster(fdDTM05, paste0(path_analysis_results_5d_iSEG05_mtpi_RG, "/fdDTM05.tif"),
                    format= "GTiff", overwrite = TRUE, NAflag = 0)
#read filtered raster
fdDTM05 <- raster::raster(paste0(path_analysis_results_5d_iSEG05_mtpi_RG, "fdDTM05.tif"))
################################################################################
####------------------------#4.INVERT THE FILTERED DTMS#--------------------####
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
ifdDTM05 <- spatialEco::raster.invert(fdDTM05)

raster::writeRaster(ifdDTM05, paste0(path_analysis_results_5d_iSEG05_mtpi_RG,
                    "/ifdDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)

#read inverse filtered DTM05
ifdDTM05 <- raster::raster(paste0(path_analysis_results_5d_iSEG05_mtpi_RG, "ifdDTM05.tif"))
################################################################################
####---------------------#5.PIT FILLING OF INVERSE FILTERED DTM#------------####
#Freeland et al. 2016 & Rom et al. use Wang and Liu 2006, which is implemented
#in Whitebox GAT & SAGA to make it simple we are going to use SAGA
#----------------------------------------SAGA----------------------------------#
#with a value of zero sinks are filled up to the spill elevation (which results in flat areas
#(from the module description)
####-----------------------#Fill Sinks (Wang & Liu 2006)#-------------------####
filled_DTM_SAGA_WL(dtm= ifdDTM05,
                   output= paste0(path_analysis_results_5d_iSEG05_mtpi_RG),
                   tmp= paste0(path_tmp),
                   minslope= 0,
                   crs= crs(traindtm05))
################################################################################
####--------------------#6.INVERSE DTM - PIT-FILLED DTM#--------------------####
#read sink filled raster
pf_ifdDTM_mtpid_WL05 <- raster::raster(paste0(path_analysis_results_5d_iSEG05_mtpi_RG, "pf_ifDTM_W&L.tif"))

#subtract inverse DTM from pit-filled DTM
diff_ifdDTM05 <- ifdDTM05 - pf_ifdDTM_mtpid_WL05

#export subtracted raster
raster::writeRaster(diff_ifdDTM05, paste0(path_analysis_results_5d_iSEG05_mtpi_RG,
                    "/diff_ifdDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####--------------------------#7.FILTER diff_ifDTM05#-----------------------####
##When checking in QGIS and making profiles along the barrows can see that there
#are a lot of small outliers which disturb when processing further
#let's use a 3x3 moving window with different filters: sum, min, max, mean,
#median, modal, sd, sobel and check in QGIS how well the barrows still are visible
#------------------------------#diff_ifdDTM05_mtpid#---------------------------#
filtered_diff_ifdDTM05<- filtR(diff_ifdDTM05, filtRs= c("all"), sizes=3, NArm=TRUE)
names(filtered_diff_ifdDTM05)
#[1] "layer_sum3"    "layer_min3"    "layer_max3"    "layer_mean3"   "layer_median3"
#[6] "layer_modal3"  "layer_sd3"     "layer_sobel3"

names(filtered_diff_ifdDTM05) <- c("fdiff_ifdDTM05_sum3", "fdiff_ifdDTM05_min3",
                                   "fdiff_ifdDTM05_max3", "fdiff_ifdDTM05_mean3",
                                   "fdiff_ifdDTM05_median3", "fdiff_ifdDTM05_modal3",
                                   "fdiff_ifdDTM05_sd3", "fdiff_ifdDTM05_sobel3")
#export filter one by one
writeRaster(filtered_diff_ifdDTM05, paste0(path_analysis_results_5d_iSEG05_mtpi_RG,
            filename = names(filtered_diff_ifdDTM05), ".tif"),
            format= "GTiff", bylayer = TRUE, overwrite=TRUE)

#after checking in QGIS it can be said that any filter which seems to be useful
#to enhance you OoI can be used in the next step.
#In general the filters median3, modal3 und mean3 proved to enhance the barrows #
#the most and suppress the rest the best. Specifically the modal filter was
#proved to enhance the burial mound in the field most clearly
################################################################################
####------------------#8.SEEDED REGION GROWING SEGMENTATIOM#----------------####
#--------------------#read the chosen filtered difference DTM#-----------------#
fdiff_ifdDTM05_median3 <- raster::raster(paste0(path_analysis_results_5d_iSEG05_mtpi_RG, "/fdiff_ifdDTM05_median3.tif"))
#--------------------------------#SEED GENERATION#-----------------------------#
#in the first step seeds are generated to be used in the actual segmentation
#NB. When using the segments from the WS segmentation the region growing does not work
#band_width, normalize, dw_weighting, dw_idw_power & dw_bandwidth are default values
generate_seedpoints_SAGA(dtm=fdiff_ifdDTM05_median3,
                         tmp=paste0(path_tmp),
                         seedtype = 1,
                         method = 1,
                         band_width = 100,
                         normalize=0,
                         dw_weighting = 1,
                         dw_idw_power=1,
                         dw_bandwidth=5,
                         crs=crs(traindtm05))
#-------------------------------#REGION GROWING#-------------------------------#
#The region growing algorithm needs seed generated by the seed generation tool
#in SAGA
# all are default values
region_growing_SAGA(seeds=paste0(path_tmp, "seedpoints.sgrd"),
                    dtm= TAfdiff_ifDTM05_median3,
                    tmp=paste0(path_tmp),
                    output=paste0(path_analysis_results_5d_iSEG05_mtpi_RG),
                    normalize=0,
                    neighbour=0,
                    method=1,
                    sig_1=0.7,
                    sig_2=1,
                    threshold=0,
                    leafsize=256,
                    crs=crs(traindtm05))
#----------------------------POLYGONIZE RG SEGMENTS----------------------------#
#class_id & all_vertices are default value
polygonize_segments_SAGA(segments=paste0(path_tmp, "segments.sgrd"),
                         tmp=paste0(path_tmp),
                         class_all=1,
                         class_id=1,
                         split=1,
                         all_vertices=0)
################################################################################
####---------------------------#9.MANIPULATE SEGMENTS#----------------------####
segments<- readOGR(paste0(path_tmp, "segments.shp"))
crs(segments) <-crs(traindtm05)
mapview(segments)
#we can see that based on the method of region growing, all the raster is segmented
#check in mapview the ID +1 or the mvFeatureId of the background segment!
#--------------------------#SUBTRACT BACKGROUND POLYGONS#----------------------#
#The ID of the two big segments is: 105 and 302; let'S subtract them
segments_purged_RG<- subset(segments, ID %in% c('0':'2258', '2260':'4003'))
mapview(segments_purged_RG)
#---------------------------------#export segments#----------------------------#
rgdal::writeOGR(obj=segments_purged_RG, dsn = "/home/keltoskytoi/repRCHrs/tmp",
                layer ="segments", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
####-------------------------#10.JOIN NEIGHBORING POLYGONS#------------------####
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
####-----------------#11.COMPUTE SHAPE INDEX OF JOINED SEGMENTS#------------####
#Polygon Shape Indices
#NB these variables are not in the tool description of SAGA 6.3 but you have to use them
compute_shape_index_SAGA(segments=paste0(path_tmp, "segments.shp"),
                         tmp=paste0(path_tmp),
                         index=paste0(path_tmp, "segments.shp"),
                         gyros=1,
                         feret=1,
                         feret_dirs=18)
####------------#12.CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#-------------####
#----------------------------#LOAD SHAPE FILES & PLOT THEM#--------------------#
segments_iSEG_mtpi_RG <- readOGR(paste0(path_tmp, "segments.shp"))
burial_mounds_5 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994.shp"))
burial_mounds_35 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994.shp"))
crs(segments_iSEG_mtpi_RG) <- crs(burial_mounds_5)
mapview::mapview(segments_iSEG_mtpi_RG) + burial_mounds_5 + burial_mounds_35
#The result is not breathtaking, but it's ok - all mounds ar represented by a
#segment - apart from Mound 1
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments_iSEG_mtpi_RG@data$compactness <- (sqrt(4*segments_iSEG_mtpi_RG@data$A/pi))/segments_iSEG_mtpi_RG@data$P
segments_iSEG_mtpi_RG@data$roundness <- (4*segments_iSEG_mtpi_RG@data$A)/(pi*segments_iSEG_mtpi_RG@data$Fmax)
segments_iSEG_mtpi_RG@data$elongation <- segments_iSEG_mtpi_RG@data$Fmax/segments_iSEG_mtpi_RG@data$Fmin

names(segments_iSEG_mtpi_RG)
#[1] "ID"          "A"           "P"           "P.A"         "P.sqrt.A."   "Depqc"
#[7] "Sphericity"  "Shape.Index" "Dmax"        "DmaxDir"     "Dmax.A"      "Dmax.sqrt.A"
#[13] "Dgyros"      "Fmax"        "FmaxDir"     "Fmin"        "FminDir"     "Fmean"
#[19] "Fmax90"      "Fmin90"      "Fvol"        "compactness"  "roundness"  "elongation"

#export the segments with the additional descriptive variables
rgdal::writeOGR(obj=segments_iSEG_mtpi_RG, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/5d_iSEG05_mtpi_RG",
                layer ="segments_purged_shape_descriptive_joined_RG", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
#in case that you want to read the segments at a later point, you will have to
#change the column names:
#segments_iSEG_mtpi_RG <- readOGR(paste0(path_analysis_results_5d_iSEG05_mtpi_RG
#                                "segments_purged_shape_descriptive_joined_RG.shp"))
#names(segments_iSEG_mtpi_RG)
#[1] "ID"      "A"       "P"       "P_A"     "P_sq_A_" "Depqc"   "Sphrcty" "Shp_Ind"
#[9] "Dmax"    "DmaxDir" "Dmax_A"  "Dmx_s_A" "Dgyros"  "Fmax"    "FmaxDir" "Fmin"
#[17] "FminDir" "Fmean"   "Fmax90"  "Fmin90"  "Fvol"    "cmpctns" "rondnss" "elongtn"
####----------------#13. THRESHOLD BASED FILTERING OF SEGMENTS--------------####
#the most descriptive segment of the mound was selected as reference for area and sphericity
#NB: the Shape Index characterizes the deviation from an optimal circle. A Shape
#Index of 1.4 - 1.7 can be seen as relatively compact but of course it depends
#on the context
#---------------basic descriptive values of burial_mounds_9 + 35---------------#
Mound_1 <- segments_iSEG_mtpi_RG[373,] #372+1
Mound_2 <- segments_iSEG_mtpi_RG[240,] #239+1
Mound_3 <- segments_iSEG_mtpi_RG[116,] #115+1
Mound_4  <- segments_iSEG_mtpi_RG[171,] #170+1
Mound_5  <- segments_iSEG_mtpi_RG[99,] #98+1
Mound_6  <- segments_iSEG_mtpi_RG[200,] #199+1
Mound_7  <- segments_iSEG_mtpi_RG[339,] #338+1
Mound_8  <- segments_iSEG_mtpi_RG[533,] #532+1
Mound_9 <- segments_iSEG_mtpi_RG[1911,] #1910+1 #
#------------------------------------------------------------------------------#
Mound_35 <- segments_iSEG_mtpi_RG[873,] #872+1

#bind the rows together:
reference_descriptors_mtpi_RG <- bind(Mound_1, Mound_2, Mound_3, Mound_4, Mound_5,
                                 Mound_6, Mound_7, Mound_8, Mound_9, Mound_35)

min(reference_descriptors_mtpi_RG$A) #34
max(reference_descriptors_mtpi_RG$A) #581.5
min(reference_descriptors_mtpi_RG$Sphericity) #0.6017071
max(reference_descriptors_mtpi_RG$Sphericity) #0.7680633
min(reference_descriptors_mtpi_RG$Shape.Index) #1.301976
max(reference_descriptors_mtpi_RG$Shape.Index) #1.661938
min(reference_descriptors_mtpi_RG$elongation) #1.070516
max(reference_descriptors_mtpi_RG$elongation) #1.455353
min(reference_descriptors_mtpi_RG$compactness) #0.1915293
max(reference_descriptors_mtpi_RG$compactness) #0.2444822
####----------------------------#MOUND  THRESHOLDS#-------------------------####
#let's filter for segments of the area, sphericity, shape index, elongation
#and compactness

#based on the experciences it is best to aim below and above the respective thresholds to get all mounds
iSEG_mtpi_RG_filt <- segments_iSEG_mtpi_RG[segments_iSEG_mtpi_RG$A <= 581.6 & segments_iSEG_mtpi_RG$A >= 33.9 &
                           segments_iSEG_mtpi_RG$Sphericity >= 0.6017070 & segments_iSEG_mtpi_RG$Sphericity <= 0.7680640 &
                           segments_iSEG_mtpi_RG$Shape.Index >= 1.301970 & segments_iSEG_mtpi_RG$Shape.Index <= 1.661940 &
                           segments_iSEG_mtpi_RG$elongation >= 1.070515 & segments_iSEG_mtpi_RG$elongation <= 1.455354 &
                           segments_iSEG_mtpi_RG$compactness >= 0.1915292 & segments_iSEG_mtpi_RG$compactness <= 0.2444823,]
mapview::mapview(iSEG_mtpi_RG_filt) + burial_mounds_5 + burial_mounds_35
#------------------------------------------------------------------------------#

rgdal::writeOGR(obj=iSEG_mtpi_RG_filt, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/5d_iSEG05_mtpi_RG",
                layer ="iSEG_mtpi_RG", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
