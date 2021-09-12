################################################################################
########################WORKFLOW DEVELOPED ON THE TESTDTM#######################
################################################################################
####-------------------------------#SHORTCUTS#------------------------------####
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
####-----------------------------#2. FILTER DTM#----------------------------####
#let's use a mean/low-pass filter with 3x3 moving window because we are looking
#for relatively delicate features
fDTM05<- filtR(traindtm05, filtRs="mean", sizes=3, NArm=TRUE)

names(fDTM05)
#"X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_05r_mean3"

#let's rename the layer
names(fDTM05) <- "fDTM05"

#export filter
raster::writeRaster(fDTM05, paste0(path_analysis_results_5c_iSEG05_RG,
                    "/fDTM05.tif"), format= "GTiff", overwrite=TRUE)
#read filtered DTM05
fDTM05 <- raster::raster(paste0(path_analysis_results_5c_iSEG05_RG, "/fDTM05.tif"))
################################################################################
####-------------------------#3.INVERT FILTERED DTM#------------------------####
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
ifDTM05 <- spatialEco::raster.invert(fDTM05)
raster::writeRaster(ifDTM05, paste0(path_analysis_results_5c_iSEG05_RG,
                    "/ifDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)

#read inverse filtered DTM05
ifDTM05 <- raster::raster(paste0(path_analysis_results_5c_iSEG05_RG, "ifDTM05.tif"))
################################################################################
####---------------------#4.PIT FILLING OF INVERSE FILTERED DTM#------------####
#Freeland et al. 2016 & Rom et al. use Wang and Liu 2006, which is implemented
#in Whitebox GAT & SAGA to make it simple we are going to use SAGA
#---------------------------------------SAGA-----------------------------------#
#with a value of zero sinks are filled up to the spill elevation (which results in flat areas
#(from the module description)
####-----------------------#Fill Sinks (Wang & Liu 2006)#-------------------####
filled_DTM_SAGA_WL(dtm= ifDTM05,
                   output= paste0(path_analysis_results_5c_iSEG05_RG),
                   tmp= paste0(path_tmp),
                   minslope= 0,
                   crs= crs(traindtm05))

#read the result of the pit-filling
pf_ifDTM_WL05 <- raster::raster(paste0(path_analysis_results_5c_iSEG05_RG, "pf_ifDTM_W&L.tif"))
################################################################################
####-----------#5.SUBRATCTION OF INVERSE DTM FROM PIT-FILLED DTM#-----------####
#subtract inverse DTM from pit-filled DTM
diff_ifDTM05 <- ifDTM05 - pf_ifDTM_WL05

raster::writeRaster(diff_ifDTM05, paste0(path_analysis_results_5c_iSEG05_RG,
                    "/diff_ifDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####-------------------------#6.FILTER diff_ifDTM05##-----------------------####
##When checking in QGIS and making profiles along the barrows can see that there
#are a lot of small outliers which disturb when processing further
#let's use a 3x3 moving window with different filters: sum, min, max, mean,
#median, modal, sd, sobel and check in QGIS how well the barrows still are visible
filtered_diff_ifDTM05<- filtR(diff_ifDTM05, filtRs= c("all"), sizes=3, NArm=TRUE)

names(filtered_diff_ifDTM05)

names(filtered_diff_ifDTM05) <- c("fdiff_ifDTM05_sum3", "fdiff_ifDTM05_min3",
                                  "fdiff_ifDTM05_max3", "fdiff_ifDTM05_mean3",
                                  "fdiff_ifDTM05_median3", "fdiff_ifDTM05_modal3",
                                  "fdiff_ifDTM05_sd3", "fdiff_ifDTM05_sobel3")
#export filter one by one
writeRaster(filtered_diff_ifDTM05, paste0(path_analysis_results_5c_iSEG05_RG,
            filename = names(filtered_diff_ifDTM05), ".tif"),
            format= "GTiff", bylayer = TRUE, overwrite=TRUE, NAflag = 0)

#After checking in QGIS it can be said that any filter which seems to be useful
#to enhance you OoI can be used in the next step. It was decided that the max
#filter restricts the non-mound areas the best way, but also it restricts the
#mounds in area but when using filters one has always to count in the loss of
#information to some extent
#################################################################################
####------------------#7. SEEDED REGION GROWING SEGMENTATIOM#---------------####
#--------------------#read the chosen filtered difference DTM#-----------------#
fdiff_ifDTM05_sd3 <- raster::raster(paste0(path_analysis_results_5c_iSEG05_RG,
                                     "/fdiff_ifDTM05_sd3.tif"))
#------------------------------#SEED GENERATION#-------------------------------#
#in the first step seeds are generated to be used in the actual segmentation
#NB. When using the segments from the WS segmentation the region growing does not work
#normalize, dw_weighting, dw_idw_power & dw_bandwidth are default values
generate_seedpoints_SAGA(dtm=fdiff_ifDTM05_sd3,
                         tmp=paste0(path_tmp),
                         seedtype = 1,
                         method = 1,
                         band_width = 100,
                         normalize=0,
                         dw_weighting = 1,
                         dw_idw_power=1,
                         dw_bandwidth=5,
                         crs=crs(traindtm05))
#---------------------------------#REGION GROWING#-----------------------------#
#normalize, neighbour, sig_2 and leafsize are at default values
region_growing_SAGA(seeds=paste0(path_tmp, "seedpoints.sgrd"),
                    dtm= TAfdiff_ifDTM05_sd3,
                    tmp=paste0(path_tmp),
                    output=paste0(path_analysis_results_5c_iSEG05_RG),
                    normalize=0,
                    neighbour=0,
                    method=1,
                    sig_1=0.7,
                    sig_2=1,
                    threshold=0.5,
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
####---------------------------#8.MANIPULATE SEGMENTS#----------------------####
segments<- readOGR(paste0(path_tmp, "segments.shp"))
crs(segments) <-crs(traindtm05)
mapview(segments)
#we can see that based on the method of region growing, all the raster is segmented
#check in mapview the ID +1 or the mvFeatureId of the background segment!
#--------------------------#SUBTRACT BACKGROUND POLYGONS#----------------------#
#The ID of the two big segments is: 105 and 302; let's subtract them
segments_purged_RG<- subset(segments, ID %in% c('0':'104', '106':'301', '303':'1035'))
mapview(segments_purged_RG)
#---------------------------------#export segments#----------------------------#
rgdal::writeOGR(obj=segments_purged_RG, dsn = "/home/keltoskytoi/repRCHrs/tmp",
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
####------------#11.CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#-------------####
#--------------------------#LOAD SHAPE FILES & PLOT THEM#----------------------#
segments_iSEG_RG <- readOGR(paste0(path_tmp, "segments.shp"))
burial_mounds_5 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994.shp"))
mapview::mapview(segments_iSEG_RG) + burial_mounds_5
#we can see, that mounds 2, 3, 7 and 8 do not have any segments
####--------------#calculate additional descriptive variables---------------####
segments_iSEG_RG@data$compactness <- (sqrt(4*segments_iSEG_RG@data$A/pi))/segments_iSEG_RG@data$P
segments_iSEG_RG@data$roundness <- (4*segments_iSEG_RG@data$A)/(pi*segments_iSEG_RG@data$Fmax)
segments_iSEG_RG@data$elongation <- segments_iSEG_RG@data$Fmax/segments_iSEG_RG@data$Fmin

names(segments_iSEG_RG)
#[1] "ID"          "A"           "P"           "P.A"         "P.sqrt.A."   "Depqc"
#[7] "Sphericity"  "Shape.Index" "Dmax"        "DmaxDir"     "Dmax.A"      "Dmax.sqrt.A"
#[13] "Dgyros"      "Fmax"        "FmaxDir"     "Fmin"        "FminDir"     "Fmean"
#[19] "Fmax90"      "Fmin90"      "Fvol"        "compactness"  "roundness"  "elongation"

#export the segments with the additional descriptive variables
rgdal::writeOGR(obj=segments_iSEG_RG, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/5c_iSEG05_RG",
                layer ="segments_purged_shape_descriptive_joined_RG", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
#in case that you want to read the segments at a later point, you will have to
#change the column names:
#segments_iSEG_RG <- readOGR(paste0(path_analysis_results_5c_iSEG05_RG
#                            "segments_purged_shape_descriptive_joined_RG.shp"))
#names(segments_iSEG_WS)
#[1] "ID"      "A"       "P"       "P_A"     "P_sq_A_" "Depqc"   "Sphrcty" "Shp_Ind"
#[9] "Dmax"    "DmaxDir" "Dmax_A"  "Dmx_s_A" "Dgyros"  "Fmax"    "FmaxDir" "Fmin"
#[17] "FminDir" "Fmean"   "Fmax90"  "Fmin90"  "Fvol"    "cmpctns" "rondnss" "elongtn"
####----------------#12. THRESHOLD BASED FILTERING OF SEGMENTS--------------####
#-------------------basic descriptive values of burial_mounds_9----------------#
#the most descriptive segment of the mound was selected as reference for area and
#sphericity
#NB: the Shape Index characterizes the deviation from an optimal circle. A Shape
#Index of 1.4 - 1.7 can be seen as relatively compact but of course it depends
#on the context

#Mound 2 was not extracted by the data preparation methods

Mound_1 <- segments_iSEG_RG[359,] #358+1
#Mound_2 <- segments_iSEG_RG[,] #
Mound_3 <- segments_iSEG_RG[278,] #277+1
Mound_4 <- segments_iSEG_RG[296,] #295+1
Mound_5 <- segments_iSEG_RG[269,] #268+1 #the inner circle
Mound_6 <- segments_iSEG_RG[302,] #301+1
Mound_7 <- segments_iSEG_RG[358,] #357+1
Mound_8 <- segments_iSEG_RG[399,] #398+1
Mound_9 <- segments_iSEG_RG[213,] #212+1
#------------------------------------------------------------------------------#
#bind the rows together:
reference_descriptors_RG <- bind(Mound_1, Mound_3, Mound_4, Mound_5, Mound_6,
                                 Mound_7, Mound_8, Mound_9)

min(reference_descriptors_RG$A) #9.75
max(reference_descriptors_RG$A) #603
min(reference_descriptors_RG$Sphericity) #0.5881687
max(reference_descriptors_RG$Sphericity) #0.7921941
min(reference_descriptors_RG$Shape.Index) #1.262317
max(reference_descriptors_RG$Shape.Index) #1.700193
min(reference_descriptors_RG$elongation) #1.109656
max(reference_descriptors_RG$elongation) #1.335749
min(reference_descriptors_RG$compactness) #0.1872199
max(reference_descriptors_RG$compactness) #0.2521632

####-----------------------------#MOUND THRESHOLDS#-------------------------####
#let's filter for segments of the Area and sphericity, shape index, elongation
#and compactness

#based on the experciences it is best to aim below and above the respective thresholds to get all mounds
segments_iSEG_RG_filt <- segments_iSEG_RG[segments_iSEG_RG$A <= 603.1 & segments_iSEG_RG$A >= 9.7 &
                         segments_iSEG_RG$Sphericity >= 0.5881680 & segments_iSEG_RG$Sphericity <= 0.7921950 &
                         segments_iSEG_RG$Shape.Index >= 1.262310 & segments_iSEG_RG$Shape.Index <=1.700200 &
                         segments_iSEG_RG$elongation >= 1.109650 & segments_iSEG_RG$elongation <=1.335750 &
                         segments_iSEG_RG$compactness >= 0.1872190 & segments_iSEG_RG$compactness <= 0.2521640,]
mapview::mapview(segments_iSEG_RG_filt) + burial_mounds_5


rgdal::writeOGR(obj=segments_iSEG_RG_filt, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/5c_iSEG05_RG",
                layer ="iSEG_RG", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
