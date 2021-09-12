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
####-------------------------#2. CREATE A DERIVATIVE##----------------------####
#-----------------write testdtm as a SAGA grid into the tmp folder-------------#
#We understood from creating derivatives, that the multiscale topographic position
#index is very useful to enhance the flatly preserved burial mounds; so we will use
#MTPI before of a filter
####------------------MULTISCALE TOPOGRAPHIC POSITION INDEX-----------------####
generate_mtpi_SAGA(dtm=traindtm05,
                   output= paste0(path_analysis_results_5b_iSEG05_mtpi_WS),
                   tmp= paste0(path_tmp),
                   scale_min=1,
                   scale_max=30,
                   scale_num=2,
                   crs=crs(traindtm05))
#read mtpi
dDTM05 <- raster::raster(paste0(path_analysis_results_5b_iSEG05_mtpi_WS, "dDTM05.tif"))
################################################################################
####--------------------------#3. FILTER DERIVATIVES#-----------------------####
#let's use a mean/low-pass filter with 3x3 moving window because we are looking
#for relatively delicate features
fdDTM05<- filtR(dDTM05, filtRs="mean", sizes=3, NArm=TRUE)

#check the name of the layer
names(fdDTM05)
#"dDTM05_mean3"

#export filter
raster::writeRaster(fdDTM05, paste0(path_analysis_results_5b_iSEG05_mtpi_WS,
                   "/fdDTM05.tif"), format= "GTiff", overwrite=TRUE)

#read filtered raster
fdDTM05 <- raster::raster(paste0(path_analysis_results_5b_iSEG05_mtpi_WS, "fdDTM05.tif"))
################################################################################
####------------------------#4.INVERT THE FILTERED DTMS#--------------------####
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
ifdDTM05 <- spatialEco::raster.invert(fdDTM05)
raster::writeRaster(ifdDTM05, paste0(path_analysis_results_5b_iSEG05_mtpi_WS,
                    "/ifdDTM05.tif"), overwrite = TRUE, NAflag = 0)

#read the result of inverted filtered raster
ifdDTM05 <- raster::raster(paste0(path_analysis_results_5b_iSEG05_mtpi_WS, "ifdDTM05.tif"))
################################################################################
####---------------------#5.PIT FILLING OF INVERSE FILTERED DTM#------------####
#Freeland et al. 2016 & Rom et al. use Wang and Liu 2006, which is implemented in Whitebox GAT & SAGA
#to make it simple we are going to use SAGA
#----------------------------------------SAGA----------------------------------#
#with a value of zero sinks are filled up to the spill elevation (which results in flat areas
#(from the module description)

####-----------------------#Fill Sinks (Wang & Liu 2006)#-------------------####
filled_DTM_SAGA_WL(dtm= ifdDTM05,
                   output= file.path(path_analysis_results_5b_iSEG05_mtpi_WS),
                   tmp= file.path(path_tmp),
                   minslope= 0,
                   crs= crs(traindtm05))
#read the result of the pit-filling
pf_ifdDTM_WL05 <- raster::raster(paste0(path_analysis_results_5b_iSEG05_mtpi_WS, "pf_ifDTM_W&L.tif"))
################################################################################
####-----------#6.SUBRATCTION OF INVERSE DTM FROM PIT-FILLED DTM#-----------####
#subtract inverse DTM from pit-filled DTM
diff_ifdDTM05 <- ifdDTM05 - pf_ifdDTM_WL05

raster::writeRaster(diff_ifdDTM05, paste0(path_analysis_results_5b_iSEG05_mtpi_WS,
                    "/diff_ifdDTM05.tif"), overwrite = TRUE, NAflag = 0)
################################################################################
####--------------------------#7.FILTER diff_ifDTM05#-----------------------####
#When checking in QGIS and making profiles along the barrows can see that there
#are a lot of small outliers which disturb when processing further
#let's use a 3x3 moving window with different filters: sum, min, max, mean,
#median, modal, sd, sobel and check in QGIS how well the barrows still are

filtered_diff_ifdDTM05<- filtR(diff_ifdDTM05, filtRs= c("all"), sizes=3, NArm=TRUE)

names(filtered_diff_ifdDTM05)
#[1] "layer_sum3"    "layer_min3"    "layer_max3"    "layer_mean3"   "layer_median3"
#[6] "layer_modal3"  "layer_sd3"     "layer_sobel3"

names(filtered_diff_ifdDTM05) <- c("fdiff_ifdDTM05_sum3", "fdiff_ifdDTM05_min3",
                                  "fdiff_ifdDTM05_max3", "fdiff_ifdDTM05_mean3",
                                  "fdiff_ifdDTM05_median3", "fdiff_ifdDTM05_modal3",
                                  "fdiff_ifdDTM05_sd3", "fdiff_ifdDTM05_sobel3")

#export filter one by one
writeRaster(filtered_diff_ifdDTM05, paste0(path_analysis_results_5b_iSEG05_mtpi_WS,
            filename = names(filtered_diff_ifdDTM05), ".tif"),
            format= "GTiff", bylayer = TRUE, overwrite=TRUE)

##After checking in QGIS it can be said that any filter which seems to be useful
#to enhance you OoI can be used in the next step.
#In general the filters median3, modal3 und mean3 proved to enhance the barrows #
#the most and suppress the rest the best. Specifically the modal filter was
#proved to enhance the burial mound in the field most clearly
#################################################################################
####------------------------#7.WATERSHED SEGMENTATION#-----------------------####
#First choose a filtered diff_ifDTM05 which characterizes the OoI the best way
fdiff_ifdDTM05_modal3 <- raster::raster(paste0(path_analysis_results_5b_iSEG05_mtpi_WS, "/fdiff_ifdDTM05_modal3.tif"))

watershed_SAGA(dtm=fdiff_ifdDTM05_modal3,
               output= paste0(path_analysis_results_5b_iSEG05_mtpi_WS),
               tmp= paste0(path_tmp),
               output_choice=0,
               down=1,
               join=1,
               threshold=0.5,
               edge=0,
               borders=0,
               crs=crs(traindtm05))
####---------------------------#POLYGONIZE WS SEGMENTS#---------------------####
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
burial_mounds_35 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994.shp"))
crs(segments)
crs(segments) <- crs(burial_mounds_5)
mapview::mapview(segments) + burial_mounds_5 + burial_mounds_35

#It is already clear that there are many small sized segments which might have
#the form and area of the burial mound segments AND the burial mounds are divided
#into multiple neighboring segments, thus these segments have to be joined together
#the following code was adapted:
#https://gis.stackexchange.com/questions/79114/joining-nearest-neighbor-small-polygons-using-r

neighb <- spdep::poly2nb(segments)
region <- create_regions(neighb)
pol_rgn <- maptools::spCbind(segments, region)
segments <- maptools::unionSpatialPolygons(pol_rgn, region)
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

mapview::mapview(segments) + burial_mounds_9 + burial_mounds_35
################################################################################
####---------------------#9.COMPUTE SHAPE INDEX OF SEGMENTS#----------------####
compute_shape_index_SAGA(segments=paste0(path_tmp, "segments.shp"),
                         tmp=paste0(path_tmp),
                         index=paste0(path_tmp, "segments.shp"),
                         gyros=1,
                         feret=1,
                         feret_dirs=18)
################################################################################
####------------#10.CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#-------------####
#--------------------------#LOAD SHAPE FILES & PLOT THEM#----------------------#
segments_iSEG_mtpi_WS <- readOGR(paste0(path_tmp, "segments.shp"))
crs(segments_iSEG_mtpi_WS)
mapview::mapview(segments_iSEG_mtpi_WS) + burial_mounds_5 + burial_mounds_35
#there area a lot of segments so it may take a while, be patient
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments_iSEG_mtpi_WS@data$compactness <- (sqrt(4*segments_iSEG_mtpi_WS@data$A/pi))/segments_iSEG_mtpi_WS@data$P
segments_iSEG_mtpi_WS@data$roundness <- (4*segments_iSEG_mtpi_WS@data$A)/(pi*segments_iSEG_mtpi_WS@data$Fmax)
segments_iSEG_mtpi_WS@data$elongation <- segments_iSEG_mtpi_WS@data$Fmax/segments_iSEG_mtpi_WS@data$Fmin

names(segments_iSEG_mtpi_WS)
#[[1] "ID"          "A"           "P"           "P.A"         "P.sqrt.A."
#[6] "Depqc"       "Sphericity"  "Shape.Index" "Dmax"        "DmaxDir"
#[11] "Dmax.A"      "Dmax.sqrt.A" "Dgyros"      "Fmax"        "FmaxDir"
#[16] "Fmin"        "FminDir"     "Fmean"       "Fmax90"      "Fmin90"
#[21] "Fvol"        "compactness" "roundness"   "elongation"

#export the segments with the additional descriptive variables
rgdal::writeOGR(obj=segments_iSEG_mtpi_WS, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/5b_iSEG05_mtpi_WS",
                layer ="segments_shape_descriptive_joined_mtpi_WS", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
#in case that you want to read the segments at a later point, you will have to
#change the column names:
#segments_iSEG_mtpi_WS <- readOGR(paste0(path_analysis_results_7b_iSEG05_mtpi_WS,
#                                 "segments_shape_descriptive_joined_mtpi_WS.shp"))
#names(segments_iSEG_mtpi_WS)
#[1] "ID"      "A"       "P"       "P_A"     "P_sq_A_" "Depqc"   "Sphrcty" "Shp_Ind"
#[9] "Dmax"    "DmaxDir" "Dmax_A"  "Dmx_s_A" "Dgyros"  "Fmax"    "FmaxDir" "Fmin"
#[17] "FminDir" "Fmean"   "Fmax90"  "Fmin90"  "Fvol"    "cmpctns" "rondnss" "elongtn"

####----------------#11. THRESHOLD BASED FILTERING OF SEGMENTS--------------####
#the most descriptive segment of the mound was selected as reference for area and sphericity
#NB: the Shape Index characterizes the deviation from an optimal circle. A Shape
#Index of 1.4 - 1.7 can be seen as relatively compact but of course it depends
#on the context
#------------------basic descriptive values of the burial mounds---------------#
Mound_5_1 <- segments_iSEG_mtpi_WS[16255,] #16254+1
Mound_5_2 <- segments_iSEG_mtpi_WS[15048,] #15047+1
Mound_5_3 <- segments_iSEG_mtpi_WS[13276,] #13275+1 #### the rounder segment was chosen
Mound_5_4 <- segments_iSEG_mtpi_WS[14004,] #14003+1
Mound_5_5 <- segments_iSEG_mtpi_WS[13112,] #13111+1
Mound_5_6 <- segments_iSEG_mtpi_WS[14436,] #14435+1
Mound_5_7 <- segments_iSEG_mtpi_WS[16299,] #16298+1
Mound_5_8 <- segments_iSEG_mtpi_WS[18685,] #18684+1
Mound_5_9 <- segments_iSEG_mtpi_WS[9675,] #9674+1 #### not very round
Mound_35 <- segments_iSEG_mtpi_WS[21997,] #21996+1 #### not the roundest either

#in short:
reference_descriptors_mtpi_WS <- bind(Mound_5_1, Mound_5_2, Mound_5_3, Mound_5_4, Mound_5_5,
                                 Mound_5_6, Mound_5_7, Mound_5_8, Mound_5_9, Mound_35)

min(reference_descriptors_mtpi_WS$A) #42.5
max(reference_descriptors_mtpi_WS$A) #606
min(reference_descriptors_mtpi_WS$Sphericity) #0.3997014
max(reference_descriptors_mtpi_WS$Sphericity) #0.6814277
min(reference_descriptors_mtpi_WS$Shape.Index) #1.467507
max(reference_descriptors_mtpi_WS$Shape.Index) #2.501868
min(reference_descriptors_mtpi_WS$elongation) #1.117087
max(reference_descriptors_mtpi_WS$elongation) #1.5084
min(reference_descriptors_mtpi_WS$compactness) #0.1272289
max(reference_descriptors_mtpi_WS$compactness) #0.2169052
####-----------------------------#MOUND THRESHOLDS#-------------------------####
#let's filter for segments of the area, sphericity, shape index, elongation
#and compactness

#based on the experiences it is best to aim below and above the respective thresholds to get all mounds
iSEG_mtpi_WS_filt <- segments_iSEG_mtpi_WS[segments_iSEG_mtpi_WS$A <= 606.5 & segments_iSEG_mtpi_WS$A >= 42 &
                                           segments_iSEG_mtpi_WS$Sphericity >= 0.3997010 & segments_iSEG_mtpi_WS$Sphericity <= 0.6814280 &
                                           segments_iSEG_mtpi_WS$Shape.Index >= 1.467500 & segments_iSEG_mtpi_WS$Shape.Index <= 2.501870 &
                                           segments_iSEG_mtpi_WS$elongation >= 1.117080 & segments_iSEG_mtpi_WS$elongation <=1.5090 &
                                           segments_iSEG_mtpi_WS$compactness >= 0.1272280 & segments_iSEG_mtpi_WS$compactness <= 0.2169060,]
mapview::mapview(iSEG_mtpi_WS_filt) + burial_mounds_5 + burial_mounds_35
#-----------------------------#EXPORT FILTERED MOUNDS#-------------------------#
rgdal::writeOGR(obj=iSEG_mtpi_WS_filt, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/7b_iSEG05_mtpi_WS",
                layer ="iSEG_mtpi_WS", driver = "ESRI Shapefile", verbose = TRUE, overwrite_layer = TRUE)
