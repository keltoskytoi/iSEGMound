################################################################################
#########################THE WORKFLOW APPLIED ON THE AoI 1######################
################################################################################
####--------------------------------SHORTCUTS-------------------------------####
lsAOI1<-  list.files(file.path(path_analysis_results_AOI_1),
                         full.names = TRUE, pattern = glob2rx("*.tif"))

lsAOI1
#[1] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_1//3dm_32480_5630_1_he_xyzirnc_ground_05.tif"
#[2] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_1//3dm_32480_5631_1_he_xyzirnc_ground_05.tif"
#[3] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_1//3dm_32480_5632_1_he_xyzirnc_ground_05.tif"
#[4] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_1//3dm_32480_5633_1_he_xyzirnc_ground_05.tif"
#[5] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_1//3dm_32481_5630_1_he_xyzirnc_ground_05.tif"
#[6] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_1//3dm_32481_5631_1_he_xyzirnc_ground_05.tif"
#[7] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_1//3dm_32481_5632_1_he_xyzirnc_ground_05.tif"
#[8] "/home/keltoskytoi/repRCHrs/analysis/results/AOI_1//AOI_1_xyzirnc_ground_05.tif"

################################################################################
####-----------------------------#1. READ DTM#------------------------------####
AOI_1 <- raster(lsAOI1[[8]])
crs(AOI_1)
#CRS arguments: +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
mapview(AOI_1)
################################################################################
####--------------------------#2. CREATE A DERIVATIVE#----------------------####
#-----------------write testdtm as a SAGA grid into the tmp folder-------------#
#We understood from creating derivatives, that the multiscale topographic position
#index is very useful to enhance the flatly preserved burial mounds; so we will use
#MTPI before a filter
####------------------MULTISCALE TOPOGRAPHIC POSITION INDEX-----------------####
generate_mtpi_SAGA(dtm=AOI_1,
                   output= paste0(path_analysis_results_7a_iSEG_AOI_1),
                   tmp= paste0(path_tmp),
                   scale_min=1,
                   scale_max=30,
                   scale_num=20,
                   crs=crs(AOI_1))
#read mtpi
TAdDTM05 <- raster::raster(paste0(path_analysis_results_7a_iSEG_AOI_1, "dDTM05.tif"))
################################################################################
####--------------------------#3. FILTER DERIVATIVE#------------------------####
#let's use a mean/low-pass filter with 3x3 moving window because we are looking
#for relatively delicate features
TAfdDTM05<- filtR(TAdDTM05, filtRs="mean", sizes=3, NArm=TRUE)

names(TAfdDTM05)
#"dDTM05_mean3"

#export filter
raster::writeRaster(TAfdDTM05, paste0(path_analysis_results_7a_iSEG_AOI_1, "/TAfdDTM05.tif"),
                    format= "GTiff", overwrite = TRUE, NAflag = 0)

#because we are writing continuously in the folder let's use the exact path
TAfdDTM05 <- raster::raster(paste0(path_analysis_results_7a_iSEG_AOI_1, "TAfdDTM05.tif"))
################################################################################
####------------------------#4.INVERT THE FILTERED DTMS#--------------------####
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
TAifdDTM05 <- spatialEco::raster.invert(TAfdDTM05)

#write inverse filtered DTM05
raster::writeRaster(TAifdDTM05, paste0(path_analysis_results_7a_iSEG_AOI_1,
                    "/TAifdDTM05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)

#read inverse filtered DTM05
TAifdDTM05 <- raster::raster(paste0(path_analysis_results_7a_iSEG_AOI_1, "/TAifdDTM05.tif"))
################################################################################
####---------------------#5.PIT FILLING OF INVERSE FILTERED DTM#------------####
#Freeland et al. 2016 & Rom et al. use Wang and Liu 2006, which is implemented in Whitebox GAT & SAGA
#to make it simple we are going to use SAGA
#----------------------------------------SAGA----------------------------------#
#with a value of zero sinks are filled up to the spill elevation (which results in flat areas
#(from the module description)
filled_DTM_SAGA_WL(dtm= TAifdDTM05,
                   output= paste0(path_analysis_results_7a_iSEG_AOI_1),
                   tmp= paste0(path_tmp),
                   minslope= 0,
                   crs= crs(AOI_1))
#read pit filled raster
TApf_ifdDTM_WL05 <- raster::raster(paste0(path_analysis_results_7a_iSEG_AOI_1, "pf_ifDTM_W&L.tif"))
################################################################################
####-----------#6.SUBRATCTION OF INVERSE DTM FROM PIT-FILLED DTM#-----------####
#subtract inverse DTM from pit-filled DTM
TAdiff_ifdDTM05 <- TAifdDTM05 - TApf_ifdDTM_WL05

raster::writeRaster(TAdiff_ifdDTM05, paste0(path_analysis_results_7a_iSEG_AOI_1,
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
writeRaster(TAfiltered_diff_ifdDTM05, paste0(path_analysis_results_7a_iSEG_AOI_1,
            filename = names(TAfiltered_diff_ifdDTM05), ".tif"),
            format= "GTiff", bylayer = TRUE, overwrite=TRUE, NAflag = 0)

#after checking in QGIS it can be said that any filter which seems to be useful
#to enhance you OoI can be used in the next step.
################################################################################
####------------------------#8.WATERSHED SEGMENTATION#----------------------####
TAfdiff_ifdDTM05_modal3 <- raster::raster(paste0(path_analysis_results_7a_iSEG_AOI_1,
                                                 "TAfdiff_ifdDTM05_modal3.tif"))

watershed_SAGA(dtm=TAfdiff_ifdDTM05_modal3,
               output= paste0(path_analysis_results_7a_iSEG_AOI_1),
               tmp= paste0(path_tmp),
               output_choice=0,
               down=1,
               join=1,
               threshold=0.5,
               edge=0,
               borders=0,
               crs=crs(AOI_1))
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

#NOTE: there are MANY segments that it can break R; thus it is easier to check
#the segments in QGIS
mapview::mapview(segments) + burial_mounds_5

#It is already clear that there are many small sized segments which might have
#the form and area of the burial mound segments AND the burial mounds are divided
#into multiple neighboring segments, thus these segments have to be joined together
#the following code was adapted:
#https://gis.stackexchange.com/questions/79114/joining-nearest-neighbor-small-polygons-using-r

#create neighbourhood list of adjacent segments
neighb <- poly2nb(segments)
region <- create_regions(neighb)
pol_rgn <- spCbind(segments, region)
segments <- unionSpatialPolygons(pol_rgn, region)
#SpP is invalid because there are self-intersections; but it still works

##NOTE: there are MANY segments that it can break R; thus it is easier to check
#the segments in QGIS
mapview::mapview(segments)
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
rgdal::writeOGR(obj=segments, dsn = "/home/keltoskytoi/repRCHrs/tmp",
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
segments_iSEG_mtpi_WS_AOI_1 <- readOGR(paste0(path_tmp, "segments.shp"))
burial_mounds_5 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "5_Dobiat_1994.shp"))
burial_mounds_7 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "7_Dobiat_1994.shp"))
burial_mounds_14 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "14_Dobiat_1994.shp"))
burial_mounds_35 <- readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "35_Dobiat_1994.shp"))
crs(segments_iSEG_mtpi_WS_AOI_1)
#do not run, might bring R to crash
#mapview::mapview(segments_iSEG_mtpi_WS_AOI_1) + burial_mounds_5 + burial_mounds_7 + burial_mounds_14 + burial_mounds_35
#------------------#CALCULATE ADDITIONAL DECRIPTIVE VARIAIBLES#----------------#
#---------------------------#after Niculitca 2020a#----------------------------#
segments_iSEG_mtpi_WS_AOI_1@data$compactness <- (sqrt(4*segments_iSEG_mtpi_WS_AOI_1@data$A/pi))/segments_iSEG_mtpi_WS_AOI_1@data$P
segments_iSEG_mtpi_WS_AOI_1@data$roundness <- (4*segments_iSEG_mtpi_WS_AOI_1@data$A)/(pi*segments_iSEG_mtpi_WS_AOI_1@data$Fmax)
segments_iSEG_mtpi_WS_AOI_1@data$elongation <- segments_iSEG_mtpi_WS_AOI_1@data$Fmax/segments_iSEG_mtpi_WS_AOI_1@data$Fmin

names(segments_iSEG_mtpi_WS_AOI_1)
# [1] "ID"          "A"           "P"           "P.A"         "P.sqrt.A."
#[6] "Depqc"       "Sphericity"  "Shape.Index" "Dmax"        "DmaxDir"
#[11] "Dmax.A"      "Dmax.sqrt.A" "Dgyros"      "Fmax"        "FmaxDir"
#[16] "Fmin"        "FminDir"     "Fmean"       "Fmax90"      "Fmin90"
#[21] "Fvol"        "compactness" "roundness"   "elongation"

#------------------------------------------------------------------------------#
#export the segments with the additional descriptive variables
rgdal::writeOGR(obj=segments_iSEG_mtpi_WS_AOI_1, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/7a_iSEG_AOI_1",
                layer ="segments_shape_descriptive_joined_mtpi_WS_AOI_1", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)
################################################################################
#in case that you want to read the segments at a later point, you will have to
#change the column names:
segments_iSEG_mtpi_WS_ta <- readOGR(paste0(path_analysis_results_7a_iSEG05_mtpi_WS_ta,
                                           "segments_shape_descriptive_joined_mtpi_WS_ta.shp"))
#names(segments_iSEG_mtpi_WS_ta)
#[1] "ID"      "A"       "P"       "P_A"     "P_sq_A_" "Depqc"   "Sphrcty" "Shp_Ind"
#[9] "Dmax"    "DmaxDir" "Dmax_A"  "Dmx_s_A" "Dgyros"  "Fmax"    "FmaxDir" "Fmin"
#[17] "FminDir" "Fmean"   "Fmax90"  "Fmin90"  "Fvol"    "cmpctns" "rondnss" "elongtn"


####----------------#12. THRESHOLD BASED FILTERING OF SEGMENTS--------------####
##the segment IDs were checked in QGIS if not R would have crashed
#NB: the Shape Index characterizes the deviation from an optimal circle. A Shape
#Index of 1.4 - 1.7 can be seen as relatively compact but of course it depends
#on the context
#------------------basic descriptive values of the burial mounds---------------#
#keep in mind, that you need to call ID+1!
#### denominates burial mound segments with amorph stucture
#------------------------#Dobiat 1994, Grave group 5#--------------------------#
Mound_5_1 <- segments_iSEG_mtpi_WS_ta[10409,] #10408+1
Mound_5_2 <- segments_iSEG_mtpi_WS_ta[9660,] #9659+1
Mound_5_3 <- segments_iSEG_mtpi_WS_ta[8590,] #8589+1
Mound_5_4 <- segments_iSEG_mtpi_WS_ta[9041,] #9040+1
Mound_5_5 <- segments_iSEG_mtpi_WS_ta[8533,] #8532+1
Mound_5_6 <- segments_iSEG_mtpi_WS_ta[9306,] #9305+1
Mound_5_7 <- segments_iSEG_mtpi_WS_ta[10419,] #10418+1
Mound_5_8 <- segments_iSEG_mtpi_WS_ta[11778,] #11777+1
Mound_5_9 <- segments_iSEG_mtpi_WS_ta[6702,] #6701+1
#------------------------#Dobiat 1994, Grave group 7#--------------------------#
#Mound_7_1 <- segments_iSEG_mtpi_WS_ta[20489,] #20488+1 #### extremely elongated
Mound_7_2 <- segments_iSEG_mtpi_WS_ta[20460,] #20459+1
Mound_7_3 <- segments_iSEG_mtpi_WS_ta[21711,] #21710+1
Mound_7_4 <- segments_iSEG_mtpi_WS_ta[23108,] #23107+1
Mound_7_5 <- segments_iSEG_mtpi_WS_ta[24409,] #24408+1
Mound_7_6 <- segments_iSEG_mtpi_WS_ta[24082,] #24081+1
Mound_7_7 <- segments_iSEG_mtpi_WS_ta[25727,] #25726+1
Mound_7_8 <- segments_iSEG_mtpi_WS_ta[26120,] #26119+1
Mound_7_9 <- segments_iSEG_mtpi_WS_ta[26204,] #26203+1
#------------------------#Dobiat 1994, Grave group 14#-------------------------#
#Mound_14_1 <- segments_iSEG_mtpi_WS_ta[60160,] #60159+1 #### has an elongated tail
Mound_14_2 <- segments_iSEG_mtpi_WS_ta[65456,] #65455+1
Mound_14_3 <- segments_iSEG_mtpi_WS_ta[58359,] #58358+1
Mound_14_4 <- segments_iSEG_mtpi_WS_ta[81481,] #81480+1
Mound_14_5 <- segments_iSEG_mtpi_WS_ta[84210,] #84209+1
#Mound_14_6 <- segments_iSEG_mtpi_WS_ta[84594,] #84593+1 ####
Mound_14_7 <- segments_iSEG_mtpi_WS_ta[87096,] #87095+1
Mound_14_8 <- segments_iSEG_mtpi_WS_ta[83486,] #83485+1 ####
Mound_14_9 <- segments_iSEG_mtpi_WS_ta[90015,] #90014+1
Mound_14_10 <- segments_iSEG_mtpi_WS_ta[90945,] #90944+1
#Mound_14_11 <- segments_iSEG_mtpi_WS_ta[88236,] #88235+1 ####
Mound_14_12 <- segments_iSEG_mtpi_WS_ta[91751,] #91750+1
#Mound_14_13 <- segments_iSEG_mtpi_WS_ta[93759,] #93758+1 #### too elongated
#Mound_14_14 <- segments_iSEG_mtpi_WS_ta[95099,] #95098+1 #### too elongated
Mound_14_15 <- segments_iSEG_mtpi_WS_ta[96873,] #96872+1
#Mound_14_16 <- segments_iSEG_mtpi_WS_ta[103663,] #103662+1 #### has an elongated tail
Mound_14_17 <- segments_iSEG_mtpi_WS_ta[105097,] #105096+1
#Mound_14_18 <- segments_iSEG_mtpi_WS_ta[106078,] #106077+1 #### has an elongated tail
Mound_14_19 <- segments_iSEG_mtpi_WS_ta[89930,] #89929+1
#------------------------#Dobiat 1994, Grave group 35#-------------------------#
Mound_35 <- segments_iSEG_mtpi_WS_ta[13882,] #13881+1

#bind the reference segments together:
#minus Mound_7_1, Mound_7_9, Mound_14_6, Mound_14_8, Mound_14_11, because their amorphity
#is small
reference_descriptors_mtpi_WS_ta <- bind(Mound_5_1, Mound_5_2, Mound_5_3, Mound_5_4,
                                         Mound_5_5, Mound_5_6, Mound_5_7, Mound_5_8,
                                         Mound_5_9, Mound_7_2, Mound_7_3, Mound_7_4,
                                         Mound_7_5, Mound_7_6, Mound_7_7, Mound_7_8,
                                         Mound_14_2, Mound_14_3, Mound_14_4,
                                         Mound_14_5, Mound_14_7, Mound_14_9, Mound_14_10,
                                         Mound_14_12, Mound_14_15, Mound_14_17,
                                         Mound_14_19, Mound_35)

#we want to filter the segments even more, thus we also use the variable roundness
min(reference_descriptors_mtpi_WS_ta$A) #45.25
max(reference_descriptors_mtpi_WS_ta$A) #576
min(reference_descriptors_mtpi_WS_ta$Sphrcty) #0.2951892
max(reference_descriptors_mtpi_WS_ta$Sphrcty) #0.6417926
min(reference_descriptors_mtpi_WS_ta$Shp_Ind) #1.558136
max(reference_descriptors_mtpi_WS_ta$Shp_Ind) #3.387658
min(reference_descriptors_mtpi_WS_ta$elongtn) #1.122967
max(reference_descriptors_mtpi_WS_ta$elongtn) #1.913615
min(reference_descriptors_mtpi_WS_ta$cmpctns) #0.09396165
max(reference_descriptors_mtpi_WS_ta$cmpctns) #0.2042889
min(reference_descriptors_mtpi_WS_ta$rondnss) #5.00867
max(reference_descriptors_mtpi_WS_ta$rondnss) #22.2683
####---------------------------#MOUND THRESHOLDS#---------------------------####
#let's filter for segments of the area, sphericity, shape index, elongation
#and compactness

#based on the experiences it is best to aim below and above the respective thresholds to get all mounds
segments_iSEG_mtpi_WS_ta_filt <- segments_iSEG_mtpi_WS_ta[segments_iSEG_mtpi_WS_ta$A <= 576.1 & segments_iSEG_mtpi_WS_ta$A >= 45.20 &
                                                            segments_iSEG_mtpi_WS_ta$Sphrcty >= 0.2951891 & segments_iSEG_mtpi_WS_ta$Sphrcty <= 0.6417927 &
                                                            segments_iSEG_mtpi_WS_ta$Shp_Ind >= 1.558135 & segments_iSEG_mtpi_WS_ta$Shp_Ind <= 3.387660 &
                                                            segments_iSEG_mtpi_WS_ta$elongtn >= 1.122960 & segments_iSEG_mtpi_WS_ta$elongtn <=1.913620 &
                                                            segments_iSEG_mtpi_WS_ta$cmpctns >= 0.09396160 & segments_iSEG_mtpi_WS_ta$cmpctns <= 0.2042890 &
                                                            segments_iSEG_mtpi_WS_ta$rondnss >= 5.00866 & segments_iSEG_mtpi_WS_ta$rondnss <= 22.2684,]
mapview::mapview(segments_iSEG_mtpi_WS_ta_filt) + burial_mounds_5 + burial_mounds_7 + burial_mounds_14 + burial_mounds_35
#------------------------------------------------------------------------------#
rgdal::writeOGR(obj=segments_iSEG_mtpi_WS_ta_filt, dsn = "/home/keltoskytoi/repRCHrs/analysis/results/8b_iSEG05_mtpi_WS_ta",
                layer ="iSEG_mtpi_WS_ta", driver = "ESRI Shapefile", verbose = TRUE, overwrite_layer = TRUE)
