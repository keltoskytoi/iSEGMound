################################################################################
#########################THE WORKFLOW APPLIED ON THE AoI 4######################
################################################################################
####--------------------------------SHORTCUTS-------------------------------####
lsAOI5<-  list.files(file.path(path_analysis_results_AOI_5),
                     full.names = TRUE, pattern = glob2rx("*.tif"))

lsAOI5
#[1] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_5//3dm_32478_5624_1_he_xyzirnc_ground_05.tif"
#[2] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_5//3dm_32479_5624_1_he_xyzirnc_ground_05.tif"
#[3] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_5//3dm_32480_5624_1_he_xyzirnc_ground_05.tif"
#[4] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_5//3dm_32481_5624_1_he_xyzirnc_ground_05.tif"
#[5] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_5//AOI_5_xyzirnc_ground_05.tif"
################################################################################
####-----------------------------#1. READ DTM#------------------------------####
AOI_5 <- raster::raster(lsAOI5[[5]])
crs(AOI_5)
#CRS arguments: +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
mapview(AOI_5)
################################################################################
####--------------------------#2. CREATE A DERIVATIVE#----------------------####
#-----------------write testdtm as a SAGA grid into the tmp folder-------------#
#We understood from creating derivatives, that the multiscale topographic position
#index is very useful to enhance the flatly preserved burial mounds; so we will use
#MTPI before a filter

####------------------MULTISCALE TOPOGRAPHIC POSITION INDEX-----------------####
generate_mtpi_SAGA(dtm=AOI_5,
                   output= paste0(path_analysis_results_7e_iSEG_AOI_5),
                   tmp= paste0(path_tmp),
                   scale_min=1,
                   scale_max=30,
                   scale_num=20,
                   crs=crs(AOI_5))
#read mtpi
TAdDTM05 <- raster::raster(paste0(path_analysis_results_7e_iSEG_AOI_5, "dDTM05.tif"))
################################################################################
####--------------------------#3. FILTER DERIVATIVE#------------------------####
#let's use a mean/low-pass filter with 3x3 moving window because we are looking
#for relatively delicate features
TAfdDTM05<- filtR(TAdDTM05, filtRs="mean", sizes=3, NArm=TRUE)

names(TAfdDTM05)
#"dDTM05_mean3"

#export filter
raster::writeRaster(TAfdDTM05, paste0(path_analysis_results_7e_iSEG_AOI_5, "/TAfdDTM05.tif"),
                    format= "GTiff", overwrite = TRUE, NAflag = 0)

#because we are writing continuously in the folder let's use the exact path
TAfdDTM05 <- raster::raster(paste0(path_analysis_results_7e_iSEG_AOI_5, "TAfdDTM05.tif"))
################################################################################
####------------------------#4.INVERT THE FILTERED DTMS#--------------------####
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
TAifdDTM05 <- spatialEco::raster.invert(TAfdDTM05)

#write inverse filtered DTM05
raster::writeRaster(TAifdDTM05, paste0(path_analysis_results_7e_iSEG_AOI_5,
                    "/TAifdDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)

#read inverse filtered DTM05
TAifdDTM05 <- raster::raster(paste0(path_analysis_results_7e_iSEG_AOI_5, "/TAifdDTM05.tif"))
################################################################################
####---------------------#5.PIT FILLING OF INVERSE FILTERED DTM#------------####
#Freeland et al. 2016 & Rom et al. use Wang and Liu 2006, which is implemented in Whitebox GAT & SAGA
#to make it simple we are going to use SAGA
#----------------------------------------SAGA----------------------------------#
#with a value of zero sinks are filled up to the spill elevation (which results in flat areas
#(from the module description)
filled_DTM_SAGA_WL(dtm= TAifdDTM05,
                   output= paste0(path_analysis_results_7e_iSEG_AOI_5),
                   tmp= paste0(path_tmp),
                   minslope= 0,
                   crs= crs(AOI_5))
#read pit filled raster
TApf_ifdDTM_WL05 <- raster::raster(paste0(path_analysis_results_7e_iSEG_AOI_5, "pf_ifDTM_W&L.tif"))
################################################################################
####-----------#6.SUBRATCTION OF INVERSE DTM FROM PIT-FILLED DTM#-----------####
#subtract inverse DTM from pit-filled DTM
TAdiff_ifdDTM05 <- TAifdDTM05 - TApf_ifdDTM_WL05

raster::writeRaster(TAdiff_ifdDTM05, paste0(path_analysis_results_7e_iSEG_AOI_5,
                    "/TAdiff_ifdDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)
################################################################################
####--------------------------#7.FILTER diff_ifDTM05#-----------------------####
#When checking in QGIS and making profiles along the barrows can see that there
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
writeRaster(TAfiltered_diff_ifdDTM05, paste0(path_analysis_results_7e_iSEG_AOI_5,
            filename = names(TAfiltered_diff_ifdDTM05), ".tif"),
            format= "GTiff", bylayer = TRUE, overwrite=TRUE, NAflag = 0)

#after checking in QGIS it can be said that any filter which seems to be useful
#to enhance you OoI can be used in the next step.
################################################################################
####------------------------#8.WATERSHED SEGMENTATION#----------------------####
TAfdiff_ifdDTM05_modal3 <- raster::raster(paste0(path_analysis_results_7e_iSEG_AOI_5,
                                          "TAfdiff_ifdDTM05_modal3.tif"))

watershed_SAGA(dtm=TAfdiff_ifdDTM05_modal3,
               output= paste0(path_analysis_results_7e_iSEG_AOI_5),
               tmp= paste0(path_tmp),
               output_choice=0,
               down=1,
               join=1,
               threshold=0.5,
               edge=0,
               borders=0,
               crs=crs(AOI_5))
#----------------------------POLYGONIZE RG SEGMENTS----------------------------#
#class_id & all_vertices are default value
polygonize_segments_SAGA(segments=paste0(path_tmp, "segments.sgrd"),
                         tmp=paste0(path_tmp),
                         class_all=1,
                         class_id=1,
                         split=1,
                         all_vertices=0)
################################################################################
####-------------------------#9.JOIN NEIGHBORING POLYGONS#------------------####
#read segments and plot them together with the burial mounds
segments <- readOGR(paste0(path_tmp, "segments.shp"))
burial_mounds_5 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994.shp"))
crs(segments) <- crs(burial_mounds_5)

mapview::mapview(segments) + burial_mounds_5

#It is already clear that there are many small sized segments which might have
#the form and area of the burial mound segments AND the burial mounds are divided
#into multiple neighboring segments, thus these segments have to be joined together
#the following code was adapted:
#https://gis.stackexchange.com/questions/79114/joining-nearest-neighbor-small-polygons-using-r

#create neighbourhood list of adjacent segments
neighb <- spdep::poly2nb(segments)
region <- create_regions(neighb)
pol_rgn <- spCbind(segments, region)
segments <- unionSpatialPolygons(pol_rgn, region)
#SpP is invalid because there are self-intersections; but it still works

##NOTE: there are MANY segments that it can break R; thus it is easier to check
#the segments in QGIS
#mapview::mapview(segments)
#---------------------#transform to a spatial polygons dataframe#--------------#
#check the class of the segments
class(segments)
#"SpatialPolygons"

#creata a data frame with the IDs of the SpatialPolygons
df<- data.frame(id = getSpPPolygonsIDSlots(segments))
row.names(df) <- getSpPPolygonsIDSlots(segments)
segments <- SpatialPolygonsDataFrame(segments, data =df)
class(segments)
#"SpatialPolygonsDataFrame"
#test projection and assign projection of original data set
crs(segments)
#------------------------#export the spatial polygons dataframe#---------------#
rgdal::writeOGR(obj=segments, dsn = "C:/Users/kelto/Documents/repRCHrs/tmp",
                layer ="segments", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
####----------------------#10.COMPUTE SHAPE INDEX SEGMENTS#-----------------####
compute_shape_index_SAGA(segments=paste0(path_tmp, "segments.shp"),
                         tmp=paste0(path_tmp),
                         index=paste0(path_tmp, "segments.shp"),
                         gyros=1,
                         feret=1,
                         feret_dirs=18)
################################################################################
#####------------#11.CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#------------####
#----------------------------#LOAD SHAPE FILES & PLOT THEM#--------------------#
segments_iSEG_mtpi_WS_AOI_5 <- readOGR(paste0(path_tmp, "segments.shp"))
burial_mounds_32632 <-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "burial_mounds_32632.shp"))
crs(segments_iSEG_mtpi_WS_AOI_5)

mapview::mapview(segments_iSEG_mtpi_WS_AOI_5) + burial_mounds_5 + burial_mounds_7 + burial_mounds_14 + burial_mounds_35
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments_iSEG_mtpi_WS_AOI_5@data$compactness <- (sqrt(4*segments_iSEG_mtpi_WS_AOI_5@data$A/pi))/segments_iSEG_mtpi_WS_AOI_5@data$P
segments_iSEG_mtpi_WS_AOI_5@data$roundness <- (4*segments_iSEG_mtpi_WS_AOI_5@data$A)/(pi*segments_iSEG_mtpi_WS_AOI_5@data$Fmax)
segments_iSEG_mtpi_WS_AOI_5@data$elongation <- segments_iSEG_mtpi_WS_AOI_5@data$Fmax/segments_iSEG_mtpi_WS_AOI_5@data$Fmin

names(segments_iSEG_mtpi_WS_AOI_5)
# [1] "ID"          "A"           "P"           "P.A"         "P.sqrt.A."
#[6] "Depqc"       "Sphericity"  "Shape.Index" "Dmax"        "DmaxDir"
#[11] "Dmax.A"      "Dmax.sqrt.A" "Dgyros"      "Fmax"        "FmaxDir"
#[16] "Fmin"        "FminDir"     "Fmean"       "Fmax90"      "Fmin90"
#[21] "Fvol"        "compactness" "roundness"   "elongation"

#------------------------------------------------------------------------------#
#export the segments with the additional descriptive variables
rgdal::writeOGR(obj=segments_iSEG_mtpi_WS_AOI_5, dsn = "C:/Users/kelto/Documents/repRCHrs/analysis/results/7e_iSEG_AOI_5",
                layer ="segments_shape_descriptive_joined_mtpi_WS_AOI_5", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
#in case that you want to read the segments at a later point, you will have to
#change the column names:
segments_iSEG_mtpi_WS_AOI_5 <- readOGR(paste0(path_analysis_results_7e_iSEG05_AOI_5,
                                           "segments_shape_descriptive_joined_mtpi_WS_AOI_5.shp"))
#names(segments_iSEG_mtpi_WS_ta)
#[1] "ID"      "A"       "P"       "P_A"     "P_sq_A_" "Depqc"   "Sphrcty" "Shp_Ind"
#[9] "Dmax"    "DmaxDir" "Dmax_A"  "Dmx_s_A" "Dgyros"  "Fmax"    "FmaxDir" "Fmin"
#[17] "FminDir" "Fmean"   "Fmax90"  "Fmin90"  "Fvol"    "cmpctns" "rondnss" "elongtn"

####----------------#12. THRESHOLD BASED FILTERING OF SEGMENTS--------------####
####---------------------------#MOUND THRESHOLDS#---------------------------####
#let's filter for segment descriptors of iSEG_mtpi_WS_ta
segments_iSEG_mtpi_WS_AOI_5_filt <- segments_iSEG_mtpi_WS_AOI_5[segments_iSEG_mtpi_WS_AOI_5$A <= 576.1 & segments_iSEG_mtpi_WS_AOI_5$A >= 45.20 &
                                                                segments_iSEG_mtpi_WS_AOI_5$Sphrcty >= 0.2951891 & segments_iSEG_mtpi_WS_AOI_5$Sphrcty <= 0.6417927 &
                                                                segments_iSEG_mtpi_WS_AOI_5$Shp_Ind >= 1.558135 & segments_iSEG_mtpi_WS_AOI_5$Shp_Ind <= 3.387660 &
                                                                segments_iSEG_mtpi_WS_AOI_5$elongtn >= 1.122960 & segments_iSEG_mtpi_WS_AOI_5$elongtn <=1.913620 &
                                                                segments_iSEG_mtpi_WS_AOI_5$cmpctns >= 0.09396160 & segments_iSEG_mtpi_WS_AOI_5$cmpctns <= 0.2042890 &
                                                                segments_iSEG_mtpi_WS_AOI_5$rondnss >= 5.00866 & segments_iSEG_mtpi_WS_AOI_5$rondnss <= 22.2684,]
mapview::mapview(segments_iSEG_mtpi_WS_AOI_5_filt) + burial_mounds_32632
#------------------------------------------------------------------------------#
rgdal::writeOGR(obj=segments_iSEG_mtpi_WS_AOI_5_filt, dsn = "C:/Users/kelto/Documents/iSEGMound/analysis/results/7e_iSEG05_AOI_5",
                layer ="iSEG_AOI_5", driver = "ESRI Shapefile", verbose = TRUE, overwrite_layer = TRUE)
