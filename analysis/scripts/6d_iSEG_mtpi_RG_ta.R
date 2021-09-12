################################################################################
#######################THE WORKFLOW APPLIED ON THE TEST AREA####################
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
trainarea05 <- raster::raster(lstrainarea[[6]])
crs(trainarea05)
#CRS arguments: +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
mapview(trainarea05)
################################################################################
####--------------------------#2. CREATE A DERIVATIVE#----------------------####
#-----------------write testdtm as a SAGA grid into the tmp folder-------------#
#We understood from creating derivatives, that the multiscale topographic position
#index is very useful to enhance the flatly preserved burial mounds; so we will use
#MTPI before a filter
####------------------MULTISCALE TOPOGRAPHIC POSITION INDEX-----------------####
generate_mtpi_SAGA(dtm=trainarea05,
                   output= paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta),
                   tmp= paste0(path_tmp),
                   scale_min=1,
                   scale_max=30,
                   scale_num=20,
                   crs=crs(trainarea05))
#read mtpi
TAdDTM05 <- raster::raster(paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta, "dDTM05.tif"))
################################################################################
####--------------------------#3. FILTER DERIVATIVE#------------------------####
#let's use a mean/low-pass filter with 3x3 moving window because we are looking
#for relatively delicate features
TAfdDTM05<- filtR(TAdDTM05, filtRs="mean", sizes=3, NArm=TRUE)

#check the name of the layer
names(TAfdDTM05)
#"dDTM05_mean3"

#export filtered raster
raster::writeRaster(TAfdDTM05, paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta,
                    "/TAfdDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)
#read filtered raster
TAfdDTM05 <- raster::raster(paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta, "TAfdDTM05.tif"))
################################################################################
####------------------------#4.INVERT THE FILTERED DTMS#--------------------####
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
TAifdDTM05 <- spatialEco::raster.invert(TAfdDTM05)

#write inverse filtered DTM05
raster::writeRaster(TAifdDTM05, paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta,
                    "/TAifdDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)

#read inverse filtered DTM05
TAifdDTM05 <- raster::raster(paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta, "TAifdDTM05.tif"))
################################################################################
####---------------------#5.PIT FILLING OF INVERSE FILTERED DTM#------------####
#Freeland et al. 2016 & Rom et al. use Wang and Liu 2006, which is implemented
#in Whitebox GAT & SAGA to make it simple we are going to use SAGA
#----------------------------------------SAGA----------------------------------#
#with a value of zero sinks are filled up to the spill elevation (which results in flat areas
#(from the module description)
####-----------------------#Fill Sinks (Wang & Liu 2006)#-------------------####
filled_DTM_SAGA_WL(dtm= TAifdDTM05,
                   output= paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta),
                   tmp= paste0(path_tmp),
                   minslope= 0,
                   crs= crs(trainarea05))
################################################################################
####--------------------#6.INVERSE DTM - PIT-FILLED DTM#--------------------####
#read pit filled raster
TApf_ifdDTM_mtpi_WL05 <- raster::raster(paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta, "pf_ifDTM_W&L.tif"))

#subtract inverse DTM from pit-filled DTM
TAdiff_ifdDTM05 <- TAifdDTM05 - TApf_ifdDTM_mtpi_WL05

#export subtracted raster
raster::writeRaster(TAdiff_ifdDTM05, paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta,
                    "/TAdiff_ifdDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####--------------------------#7.FILTER diff_ifDTM05#-----------------------####
##When checking in QGIS and making profiles along the barrows can see that there
#are a lot of small outliers which disturb when processing further
#let's use a 3x3 moving window with different filters: sum, min, max, mean,
#median, modal, sd, sobel and check in QGIS how well the barrows still are visible

TAfiltered_diff_ifdDTM05<- filtR(TAdiff_ifdDTM05, filtRs= c("all"), sizes=3, NArm=TRUE)

names(TAfiltered_diff_ifdDTM05)
#[1] "layer_sum3"    "layer_min3"    "layer_max3"    "layer_mean3"
#[5] "layer_median3" "layer_modal3"  "layer_sd3"     "layer_sobel3"

names(TAfiltered_diff_ifdDTM05) <- c("TAfdiff_ifdDTM05_sum3", "TAfdiff_ifdDTM05_min3",
                                     "TAfdiff_ifdDTM05_max3", "TAfdiff_ifdDTM05_mean3",
                                     "TAfdiff_ifdDTM05_median3", "TAfdiff_ifdDTM05_modal3",
                                     "TAfdiff_ifdDTM05_sd3", "TAfdiff_ifdDTM05_sobel3")
#export filter one by one
writeRaster(TAfiltered_diff_ifdDTM05, paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta,
            filename = names(TAfiltered_diff_ifdDTM05), ".tif"),
            format= "GTiff", bylayer = TRUE, overwrite=TRUE, NAflag = 0)

#after checking in QGIS it can be said that any filter which seems to be useful
#to enhance you OoI can be used in the next step.
#In general the filters median3, modal3 und mean3 proved to enhance the barrows #
#the most and suppress the rest the best. Specifically the modal filter was
#proved to enhance the burial mound in the field most clearly
################################################################################
####------------------#8.SEEDED REGION GROWING SEGMENTATIOM#----------------####
#--------------------#read the chosen filtered difference DTM#-----------------#
TAfdiff_ifdDTM05_modal3 <- raster::raster(paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta, "/TAfdiff_ifdDTM05_modal3.tif"))
#--------------------------------#SEED GENERATION#-----------------------------#
#in the first step seeds are generated to be used in the actual segmentation
#NB. When using the segments from the WS segmentation the region growing does not work
#band_width, normalize, dw_weighting, dw_idw_power & dw_bandwidth are default values
generate_seedpoints_SAGA(dtm=TAfdiff_ifdDTM05_modal3,
                         tmp=paste0(path_tmp),
                         seedtype = 1,
                         method = 1,
                         band_width = 100,
                         normalize=0,
                         dw_weighting = 1,
                         dw_idw_power=1,
                         dw_bandwidth=5,
                         crs=crs(ttrainarea05))
#-------------------------------#REGION GROWING#-------------------------------#
#The region growing algorithm needs seed generated by the seed generation tool
#in SAGA
# all are default values
region_growing_SAGA(seeds=paste0(path_tmp, "seedpoints.sgrd"),
                    dtm= TAfdiff_ifDTM05_modal3,
                    tmp=paste0(path_tmp),
                    output=paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta),
                    normalize=0,
                    neighbour=0,
                    method=1,
                    sig_1=0.7,
                    sig_2=1,
                    threshold=0,
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
####---------------------------#9.MANIPULATE SEGMENTS#----------------------####
segments<- readOGR(paste0(path_tmp, "segments.shp"))
crs(segments) <-crs(trainarea05)
mapview(segments)

#we can see that based on the method of region growing, all the raster is segmented
#check in mapview the ID +1 of the background segment!
#--------------------------#SUBTRACT BACKGROUND POLYGON#-----------------------#
#The ID of the big segments is: 6492
segments_purged_mtpi_RG_ta<- subset(segments, ID %in% c('0':'6491','6493':'11325'))
mapview(segments_purged_mtpi_RG_ta)
#---------------------------------#export segments#----------------------------#
rgdal::writeOGR(obj=segments_purged_mtpi_RG_ta, dsn = "/home/keltoskytoi/repRCHrs/tmp",
                layer ="segments", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
####------------------------#10.JOIN NEIGHBORING POLYGONS#------------------####
#It is visible that there are many small sized segments which might have the
#form and area of the burial mound segments AND the burial mounds are divided
#into multiple neighboring segments, thus these segments have to be joined together
#the following code was adapted:
#https://gis.stackexchange.com/questions/79114/joining-nearest-neighbor-small-polygons-using-r
segments <- readOGR(paste0(path_tmp, "segments.shp"))
mapview(segments)

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
segments_iSEG_mtpi_RG_ta <- readOGR(paste0(path_tmp, "segments.shp"))
burial_mounds_5 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994.shp"))
burial_mounds_7 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "7_Dobiat_1994.shp"))
burial_mounds_14 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "14_Dobiat_1994.shp"))
burial_mounds_35 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994.shp"))
mapview::mapview(segments_iSEG_mtpi_RG_ta) + burial_mounds_5 + burial_mounds_7 +burial_mounds_14 + burial_mounds_35
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments_iSEG_mtpi_RG_ta@data$compactness <- (sqrt(4*segments_iSEG_mtpi_RG_ta@data$A/pi))/segments_iSEG_mtpi_RG_ta@data$P
segments_iSEG_mtpi_RG_ta@data$roundness <- (4*segments_iSEG_mtpi_RG_ta@data$A)/(pi*segments_iSEG_mtpi_RG_ta@data$Fmax)
segments_iSEG_mtpi_RG_ta@data$elongation <- segments_iSEG_mtpi_RG_ta@data$Fmax/segments_iSEG_mtpi_RG_ta@data$Fmin

names(segments_iSEG_mtpi_RG_ta)
#[1] "ID"          "A"           "P"           "P.A"         "P.sqrt.A."   "Depqc"
#[7] "Sphericity"  "Shape.Index" "Dmax"        "DmaxDir"     "Dmax.A"      "Dmax.sqrt.A"
#[13] "Dgyros"      "Fmax"        "FmaxDir"     "Fmin"        "FminDir"     "Fmean"
#[19] "Fmax90"      "Fmin90"      "Fvol"        "compactness" "elongation"  "roundness"

#export the segments with the additional descriptive variables
#note that when you export a shapefile, GDAL is truncating the variable names - can be
rgdal::writeOGR(obj=segments_iSEG_mtpi_RG_ta, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/6d_iSEG05_mtpi_RG_ta",
                layer ="segments_purged_shape_descriptive_joined_mtpi_RG_ta", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
#in case that you want to read the segments at a later point, you will have to
#change the column names:
#segments_iSEG_mtpi_RG_ta <- readOGR(paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta,
#                                    "segments_purged_shape_descriptive_joined_mtpi_RG_ta.shp"))
#names(segments_iSEG_mtpi_RG_ta)
#[1] "ID"      "A"       "P"       "P_A"     "P_sq_A_" "Depqc"   "Sphrcty" "Shp_Ind"
#[9] "Dmax"    "DmaxDir" "Dmax_A"  "Dmx_s_A" "Dgyros"  "Fmax"    "FmaxDir" "Fmin"
#[17] "FminDir" "Fmean"   "Fmax90"  "Fmin90"  "Fvol"    "cmpctns" "rondnss" "elongtn"
####----------------#13. THRESHOLD BASED FILTERING OF SEGMENTS--------------####
#the most descriptive segment of the mound was selected as reference for area and sphericity
#NB: the Shape Index characterizes the deviation from an optimal circle. A Shape
#Index of 1.4 - 1.7 can be seen as relatively compact but of course it depends
#on the context
#neither of the mounds is really round, many area amorph or have an elongated tail
#------------------------#Dobiat 1994, Grave group 5#--------------------------#
Mound_5_1 <- segments_iSEG_mtpi_RG_ta[4363,] #4362+1
Mound_5_2 <- segments_iSEG_mtpi_RG_ta[4322,] #4321+1
Mound_5_3 <- segments_iSEG_mtpi_RG_ta[4248,] #4247 +1
Mound_5_4 <- segments_iSEG_mtpi_RG_ta[4283,] #4282+1
Mound_5_5 <- segments_iSEG_mtpi_RG_ta[4237,] #4236+1
Mound_5_6 <- segments_iSEG_mtpi_RG_ta[4293,] #4292+1
Mound_5_7 <- segments_iSEG_mtpi_RG_ta[4369,] #4368+1
Mound_5_8 <- segments_iSEG_mtpi_RG_ta[4449,] #4448+1
Mound_5_9 <- segments_iSEG_mtpi_RG_ta[4107,] #4106+1
#------------------------#Dobiat 1994, Grave group 7#--------------------------#
Mound_7_1 <- segments_iSEG_mtpi_RG_ta[5008,] #5007+1
Mound_7_2 <- segments_iSEG_mtpi_RG_ta[4963,] #4962+1
Mound_7_3 <- segments_iSEG_mtpi_RG_ta[5050,] #5049+1
#Mound_7_4 <- segments_iSEG_mtpi_RG_ta[,] #
Mound_7_5 <- segments_iSEG_mtpi_RG_ta[5206,] #5205+1
Mound_7_6 <- segments_iSEG_mtpi_RG_ta[5188,] #5187+1
#Mound_7_7 <- segments_iSEG_mtpi_RG_ta[5277,] #5276+1 ####very small segment
Mound_7_8 <- segments_iSEG_mtpi_RG_ta[5324,] #5323 +1
#Mound_7_9 <- segments_iSEG_mtpi_RG_ta[5315,] #5314 +1 ####very small segment
#------------------------#Dobiat 1994, Grave group 14#--------------------------#
Mound_14_1 <- segments_iSEG_mtpi_RG_ta[6501,] #6500+1
Mound_14_2 <- segments_iSEG_mtpi_RG_ta[6833,] #6832+1
#Mound_14_3 <- segments_iSEG_mtpi_RG_ta[,] #
Mound_14_4 <- segments_iSEG_mtpi_RG_ta[507,] #506+1
Mound_14_5 <- segments_iSEG_mtpi_RG_ta[690,] #689+1 #### segment has a tail = partly elongated
Mound_14_6 <- segments_iSEG_mtpi_RG_ta[741,] #740+1 #### segment is a lot smaller than the mound
Mound_14_7 <- segments_iSEG_mtpi_RG_ta[855,] #854+1
#Mound_14_8 <- segments_iSEG_RG_ta[863,] #862+1 #### too elongated
Mound_14_9 <- segments_iSEG_mtpi_RG_ta[1011,] #1010+1
Mound_14_10 <- segments_iSEG_mtpi_RG_ta[1045,] #1044+1
Mound_14_11 <- segments_iSEG_mtpi_RG_ta[937,] #936+1
Mound_14_12 <- segments_iSEG_mtpi_RG_ta[1094,] #1093 +1
Mound_14_13 <- segments_iSEG_mtpi_RG_ta[1195,] #1194+1
#Mound_14_14 <- segments_iSEG_RG_ta[1272,] #1271+1 ####segment attached to other segment
Mound_14_15 <- segments_iSEG_mtpi_RG_ta[1345,] #1344+1
Mound_14_16 <- segments_iSEG_mtpi_RG_ta[1787,] #1786+1
Mound_14_17 <- segments_iSEG_mtpi_RG_ta[1830,] #1829+1 #### segment is partly elongated
Mound_14_18 <- segments_iSEG_mtpi_RG_ta[1899,] #1898+1
Mound_14_19 <- segments_iSEG_mtpi_RG_ta[998,] #997+1
#------------------------#Dobiat 1994, Grave group 35#-------------------------#
Mound_35 <- segments_iSEG_mtpi_RG_ta[4582,] #4581+1

#bind the rows together:
reference_descriptors_mtpi_RG_ta <- bind(Mound_5_1, Mound_5_2, Mound_5_3, Mound_5_4,
                                         Mound_5_5, Mound_5_6, Mound_5_7, Mound_5_8,
                                         Mound_5_9, Mound_7_1, Mound_7_2, Mound_7_3,
                                         Mound_7_5, Mound_7_6, Mound_7_8,
                                         Mound_14_1, Mound_14_2, Mound_14_4,
                                         Mound_14_5, Mound_14_6, Mound_14_7, Mound_14_9,
                                         Mound_14_10, Mound_14_11, Mound_14_12,
                                         Mound_14_13,  Mound_14_15, Mound_14_16,
                                         Mound_14_17, Mound_14_18, Mound_14_19,
                                         Mound_35)

min(reference_descriptors_mtpi_RG_ta$A) #24.5
max(reference_descriptors_mtpi_RG_ta$A) #548.75
min(reference_descriptors_mtpi_RG_ta$Sphericity) #0.4082851
max(reference_descriptors_mtpi_RG_ta$Sphericity) #0.6077885
min(reference_descriptors_mtpi_RG_ta$Shape.Index) #1.645309
max(reference_descriptors_mtpi_RG_ta$Shape.Index) #2.449269
min(reference_descriptors_mtpi_RG_ta$elongation) #1.10163
max(reference_descriptors_mtpi_RG_ta$elongation) #1.508095
min(reference_descriptors_mtpi_RG_ta$compactness) #0.1299612
max(reference_descriptors_mtpi_RG_ta$compactness) #0.1934651
####----------------------------#MOUND  THRESHOLDS#-------------------------####
#let's filter for segments of the area, sphericity, shape index, elongation
#and compactness

iSEG_mtpi_RG_ta_filt <- segments_iSEG_mtpi_RG_ta[segments_iSEG_mtpi_RG_ta$A <= 549 & segments_iSEG_mtpi_RG_ta$A >= 24.4 &
                                         segments_iSEG_mtpi_RG_ta$Sphericity >= 0.4082850 & segments_iSEG_mtpi_RG_ta$Sphericity <= 0.6077890 &
                                         segments_iSEG_mtpi_RG_ta$Shape.Index >= 1.645300 & segments_iSEG_mtpi_RG_ta$Shape.Index <= 2.449270 &
                                         segments_iSEG_mtpi_RG_ta$elongation >= 1.10160 & segments_iSEG_mtpi_RG_ta$elongation <= 1.508100 &
                                         segments_iSEG_mtpi_RG_ta$compactness >= 0.1299610 & segments_iSEG_mtpi_RG_ta$compactness <= 0.1934655,]
mapview::mapview(iSEG_mtpi_RG_ta_filt) + burial_mounds_5 + burial_mounds_7 + burial_mounds_14 + burial_mounds_35
#------------------------------------------------------------------------------#
rgdal::writeOGR(obj=iSEG_mtpi_RG_ta_filt, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/6d_iSEG05_mtpi_RG_ta",
                layer ="iSEG_mtpi_RG_ta", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
