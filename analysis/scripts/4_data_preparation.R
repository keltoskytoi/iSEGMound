################################################################################
#######################GENERATE DERIVATIVES OF THE TRAIN DTM####################
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
####------------------------------#PREAMBLE#--------------------------------####
#--In this script different derivatives are being computed for the train DTM---#
################################################################################
####-----------------------------#LOAD TRAIN DTM#---------------------------####
traindtm05 <- raster::raster(lstrainarea[[3]])
traindtm05
#values     : 181.3, 259.38  (min, max)
#let'S rename the Training DTM for easier handling of the layer name
names(traindtm05) <- "traindtm05"

#locate the test area and map it
my_colors <- terrain.colors(200)
mapview::mapviewOptions(mapview.maxpixels = traindtm05@ncols*traindtm05@nrows/100)
mapview::mapview(traindtm05, col.regions = my_colors, legend = TRUE)

#you can see that the area is in the right spot!
################################################################################
####--------------------#CALCULATE DIFFERENT DERIVATIVES#-------------------####
#In the following you will calculate different derivatives - that is representations
#of the area in question. The main idea behind calculating derivatives is to enhance
#the geomorphological properties of any area. Based on the specific trait of the area
#in question the necessary derivatives may vary for the different research projects.
#In our case the area is more flat than hilly but with multiple shallow plateaus,
#which are sadly of similar height as the burial mounds which themselves are also
#quite flat: around 0.5 m in height. Thus the aim is here to enhance/exaggerate
#the local scale by generating derivatives. See the respective passage in the thesis.
################################################################################
####----------------------------#raster::focal()#---------------------------####
####----------------------#calculating filters: 1-16#-----------------------####
#1_sum3, 2_sum5, 3_min3, 4_min_5, 5_max_3, 6_max_5, 7_mean_3, 8_mean_5,
#9_median_3, 10_median_5 11_modal_3, 12_modal_5, 13_sd_3, 14_sd_5, 15_sobel_3,
#16_sobel_5

#sum, min, max, mean, median, modal, sd & sobel filters have been implemented in
#the function "filtR", which is a modified version from a filter function from a
#Master course work done together with Andreas Schönberg

filter_traindtm05<- filtR(traindtm05, filtRs="all", sizes=c(3,5), NArm=TRUE)

names(filter_traindtm05)
#[1] "traindtm05_sum3"    "traindtm05_sum5"    "traindtm05_min3"    "traindtm05_min5"
#[5] "traindtm05_max3"    "traindtm05_max5"    "traindtm05_mean3"   "traindtm05_mean5"
#[9] "traindtm05_median3" "traindtm05_median5" "traindtm05_modal3"  "traindtm05_modal5"
#[13] "traindtm05_sd3"     "traindtm05_sd5"     "traindtm05_sobel3"  "traindtm05_sobel5"

#export filter
writeRaster(filter_traindtm05, paste0(path_analysis_results_derivatives,
                               filename = names(filter_traindtm05), ".tif"),
                               format= "GTiff", bylayer = TRUE, overwrite=TRUE)
################################################################################
#until this point the derivatives were given number per hand
####----------------------------#raster::terrain#---------------------------####
####----#17_tri, 18_tpi, 19_roughness, 20_slope, 21_aspect, 22_flowdir#-----####
#There are many possiblities to calculate terrain indices in R as well:
#from the raster::terrain description:
#When neighbors=4, Slope and aspect Are computed according to Fleming and Hoffer
#(1979) and Ritter (1987); when neigbors=8, slope and aspect are computed according
#to Horn (1981). The Horn algorithm may be best for rough surfaces, and the
#Fleming and Hoffer algorithm may be better for smoother surfaces (Jones, 1997;
#Burrough and McDonnell, 1998). We do have a smooth surface, so: neighbors=4

#flowdir returns the 'flow direction' (of water), i.e. the direction of the
#greatest drop in elevation (or the smallest rise if all neighbors are higher).

#The terrain indices are according to Wilson et al. (2007), as in gdaldem.
#TRI (Terrain Ruggedness Index) is the mean of the absolute differences between
#the value of a cell and the value of its 8 surrounding cells. TPI (Topographic
#Position Index) is the difference between the value of a cell and the mean
#value of its 8 surrounding cells. Roughness is the difference between the
#maximum and the minimum value of a cell and its 8 surrounding cells.

#17_tri, 18_tpi, 19_roughness, 20_slope, 21_aspect, 22_flowdir

derivatives05 <- raster::terrain(traindtm05, opt = c("slope", "aspect", "TPI",
                                                    "TRI", "roughness", "flowdir"),
                                                    unit="degrees", neighbors = 4)
names(derivatives05)
#"tri"  "tpi"  "roughness"  "slope"  "aspect" "flowdir"

writeRaster(derivatives05, paste0(path_analysis_results_derivatives,
                                  filename = names(derivatives05), "05.tif"), format= "GTiff",
                                  bylayer = TRUE, overwrite=TRUE)

#the respective derivatives have been tested with 8 neighbours but no difference
#was seen, so 4 neighbours are used
################################################################################
####------------------------------#spatialEco::#----------------------------####
#the underlying algorithms and terrain indices differ from those of raster::terrain,
#so it is worth a try to calculate them too and compare them visually in QGIS, which
#one of them brings out the geomorphometry of burial mounds the best/better
####----------------------#23 TRI = Terrain Ruggedness Index----------------####
#implementation of Riley et al. (1999)
TRI05 <- spatialEco::tri(traindtm05, s = c(3,3), exact = TRUE,
                          file.name = paste0(path_analysis_results_derivatives, "23_TRI05.tif"),
                          Format= "GTiff", overwrite = TRUE)
####----------------------#24 TPI = Topographic Position Index#----------------####
#calculates topographic position using mean deviations
#if normalize & zero correct = TRUE, then the points are strongly decimated
#if normalize = FALSE & zero correction = TRUE, then the area is flattened
#if normalize = TRUE & zero correction = FALSE, then the area in rugged but clearly displays the barrows
#if normalize & zero correct = FALSE, then it is the same as normalize = FALSE & zero correction = TRUE

#Thus only normalize = TRUE & zero correction = FALSE was used
TPI05 <- spatialEco::tpi(traindtm05, scale = 3, win = "rectangle", normalize = TRUE, zero.correct = FALSE)
raster::writeRaster(TPI05, paste0(path_analysis_results_derivatives, "24_TPI05.tif"),
                    Format= "GTiff", overwrite = TRUE)
####----------------------#25 VRM Vector Ruggedness Measure#-------------------####
#implementation of Sappington et al 2007
VRM05 <- spatialEco::vrm(traindtm05, s = c(3,3),
                         file.name = paste0(path_analysis_results_derivatives, "25_VRM05.tif"),
                         format= "GTiff", overwrite = TRUE)
####------------------------------#26-29 CURVATURE#-------------------------####
#Calculates Zevenbergen & Thorne, McNab's or Bolstad's curvature
#see help for explanation
PROF_CURV05 <- spatialEco::curvature(traindtm05, type = "profile")
writeRaster(PROF_CURV05, paste0(path_analysis_results_derivatives, filename = "26_PROF_CURV05.tif"),
            format= "GTiff", overwrite=TRUE)

TOT_CURV05 <- spatialEco::curvature(traindtm05, type = "total")
writeRaster(TOT_CURV05, paste0(path_analysis_results_derivatives, filename = "27_TOT_CURV05.tif"),
            format= "GTiff", overwrite=TRUE)

MCNAB_CURV05 <- spatialEco::curvature(traindtm05, type = "mcnab")
writeRaster(MCNAB_CURV05, paste0(path_analysis_results_derivatives, filename = "28_MCNAB_CURV05.tif"),
            format= "GTiff", overwrite=TRUE)

BOLST_CURV05 <- spatialEco::curvature(traindtm05, type = "bolstad")
writeRaster(BOLST_CURV05, paste0(path_analysis_results_derivatives, filename = "29_BOLST_CURV05.tif"),
            format= "GTiff", overwrite=TRUE)
####--------------------------#30 SURFACE RELIEF RATIO#---------------------####
#Pike's (1971) Surface Relief Ratio; Describes rugosity in continuous raster
#surface within a specified window. The implementation of
#SRR can be shown as: (mean(x) - min(x)) / (max(x) - min(x))
SRR05 <- spatialEco::srr(traindtm05, s = c(3,3))
writeRaster(SRR05, paste0(path_analysis_results_derivatives, filename = "30_SRR05.tif"),
            format= "GTiff", overwrite=TRUE)
####--------------------------#31 SURFACE AREA RATIO#-----------------------####
#Berry (2002) Surface Area Ratio based on slope, calculated as:
#resolution^2 * cos( (degrees(slope) * (pi / 180)) )

SAR05 <- spatialEco::sar(traindtm05)
writeRaster(SAR05, paste0(path_analysis_results_derivatives,
                          filename = "31_SAR05.tif"), format= "GTiff",overwrite=TRUE)
####-------------------------------32 DISSECTION-------------------------------####
#Calculates the Evans (1972) Martonne's modified dissection
DISS05 <- spatialEco::dissection(traindtm05, s = c(3,3))
writeRaster(DISS05, paste0(path_analysis_results_derivatives,
                          filename = "32_DISS05.tif"), format= "GTiff", overwrite=TRUE)
####-------------------------33 HIERARCHICAL SLOPE POSITION--------------------####
#After: Murphy M.A., J.S. Evans, and A.S. Storfer (2010) Quantify Bufo boreas
#connectivity in Yellowstone National Park with landscape genetics. Ecology 91:252-261
HSP05 <- spatialEco::hsp(traindtm05, min.scale = 3, max.scale = 7, inc = 2,
                         win = "rectangle", normalize = TRUE)
writeRaster(HSP05, paste0(path_analysis_results_derivatives, filename = "33_HSP05.tif"),
            format= "GTiff",overwrite=TRUE)
####--------------------34 RASTER MULTIDIMENSIONAL SCALING (MDS)---------------####
#Multidimensional scaling of raster values within an N x N focal window
#window.median = FALSE then the center value of the matrix is returned and not the median of the matrix
#after Quinn, G.P., & M.J. Keough (2002)
MDS05 <- spatialEco::raster.mds(traindtm05, s = c(3,3))
writeRaster(MDS05, paste0(path_analysis_results_derivatives, filename = "34_MDS05.tif"),
            format= "GTiff",overwrite=TRUE)
####------------------------------35-43 RASTER DEVIATION--------------------------####
#Calculates the local deviation from the raster, a specified global statistic or
#a polynomial trend of the raster. After Magee 1998 & Fan 1996

DEV_TREND1_05 <- spatialEco::raster.deviation(traindtm05, type = "trend", degree = 1)
writeRaster(DEV_TREND1_05, paste0(path_analysis_results_derivatives,
            filename = "35_DEV_TREND1_05.tif"), format= "GTiff",overwrite=TRUE)

DEV_TREND2_05 <- spatialEco::raster.deviation(traindtm05, type = "trend", degree = 2)
writeRaster(DEV_TREND2_05, paste0(path_analysis_results_derivatives,
            filename = "36_DEV_TREND2_05.tif"), format= "GTiff",overwrite=TRUE)

DEV_MIN_local05 <- spatialEco::raster.deviation(traindtm05, type = "min", s = 3, global = FALSE)
writeRaster(DEV_MIN_local05, paste0(path_analysis_results_derivatives,
            filename = "37_DEV_MIN_local05.tif"), format= "GTiff",overwrite=TRUE)

DEV_MIN_global05 <- spatialEco::raster.deviation(traindtm05, type = "min", s = 3, global = TRUE)
writeRaster(DEV_MIN_global05, paste0(path_analysis_results_derivatives,
            filename = "38_DEV_MIN_global05.tif"), format= "GTiff",overwrite=TRUE)

DEV_MAX_local05 <- spatialEco::raster.deviation(traindtm05, type = "max", s = 3, global = FALSE)
writeRaster(DEV_MAX_local05, paste0(path_analysis_results_derivatives,
            filename = "39_DEV_MAX_local05.tif"), format= "GTiff",overwrite=TRUE)

DEV_MAX_global05 <- spatialEco::raster.deviation(traindtm05, type = "max", s = 3, global = TRUE)
writeRaster(DEV_MAX_global05, paste0(path_analysis_results_derivatives,
            filename = "40_DEV_MAX_global05.tif"), format= "GTiff",overwrite=TRUE)

DEV_MEAN_local05 <- spatialEco::raster.deviation(traindtm05, type = "mean", s = 3, global = FALSE)
writeRaster(DEV_MEAN_local05, paste0(path_analysis_results_derivatives,
            filename = "41_DEV_MEAN_local05.tif"), format= "GTiff",overwrite=TRUE)

DEV_MEAN_global05 <- spatialEco::raster.deviation(traindtm05, type = "mean", s = 3, global = TRUE)
writeRaster(DEV_MEAN_global05, paste0(path_analysis_results_derivatives,
            filename = "42_DEV_MEAN_global05.tif"), format= "GTiff",overwrite=TRUE)

DEV_MEDIAN_local05 <-spatialEco::raster.deviation(traindtm05, type = "median", s = 3, global = FALSE)
writeRaster(DEV_MEDIAN_local05, paste0(path_analysis_results_derivatives,
            filename = "43_DEV_MEDIAN_local05.tif"), format= "GTiff",overwrite=TRUE)

DEV_SD_local05 <-spatialEco::raster.deviation(traindtm05, type = "sd", s = 3, global = TRUE)
writeRaster(DEV_SD_local05, paste0(path_analysis_results_derivatives,
            filename = "44_DEV_SD_local05.tif"), format= "GTiff",overwrite=TRUE)

DEV_SD_global05 <-spatialEco::raster.deviation(traindtm05, type = "sd", s = 3, global = TRUE)
writeRaster(DEV_SD_global05, paste0(path_analysis_results_derivatives,
            filename = "45_DEV_SD_global05.tif"), format= "GTiff",overwrite=TRUE)
####----------------------------46 GAUSSIAN SMOOTHING--------------------------####
#sigma = 1, n = 3 vs. sigma = 2, n = 3 no difference, only when type=max;
#sigma 2 vs. sigma 5, n = 3 with type=max shows no difference at all;
#the rise in sigma makes only slight difference in this area, only when the moving
#window gets bigger is a difference visible but that makes the barrows unclear
#the choice
GAUSS05 <- spatialEco::raster.gaussian.smooth(traindtm05, sigma = 2, n = 3, type = max)
writeRaster(GAUSS05, paste0(path_analysis_results_derivatives, filename = "46_GAUSS05.tif"),
            format= "GTiff",overwrite=TRUE)
####---------------------------------47-49 SOBAL-------------------------------####
#The Sobel-Feldman operator is a discrete differentiation operator, deriving an
#approximation of the gradient of the intensity function. Abrupt discontinuity
#in the gradient function represents edges, making this a common approach for edge detection.
#After Sobel - Feldman 1969
SOBAL_INT05 <- spatialEco::sobal(traindtm05, method = "intensity",
                                 filename =  paste0(path_analysis_results_derivatives, "47_SOBAL_INT_05.tif"),
                                 format= "GTiff", overwrite=TRUE)

SOBAL_DIR05 <- spatialEco::sobal(traindtm05, method = "direction",
                                 filename =  paste0(path_analysis_results_derivatives, "48_SOBAL_DIR_05.tif"),
                                 format= "GTiff", overwrite=TRUE)

SOBAL_EDGE05 <- spatialEco::sobal(traindtm05, method = "edge",
                                 filename =  paste0(path_analysis_results_derivatives, "49_SOBAL_EDGE_05.tif"),
                                 format= "GTiff", overwrite=TRUE)
####------------50-51 SPHERICAL VARIANCE/STANDARD DEVIATION OF SURFACE------------####
#Derives the spherical variance or standard deviation of a raster surface

SPH_VAR05 <- spatialEco::spherical.sd(traindtm05, d = 3, variance = FALSE,
                         filename =  paste0(path_analysis_results_derivatives, "50_SPH_VAR_05.tif"),
                         format= "GTiff", overwrite=TRUE)
STD_DEV05 <- spatialEco::spherical.sd(traindtm05, d = 3, variance = TRUE,
                                      filename =  paste0(path_analysis_results_derivatives, "51_STD_DEV_05.tif"),
                                  format= "GTiff", overwrite=TRUE)
################################################################################
####-------------------------------whitebox::-------------------------------####
####----------------------52-57 MAX ELEVATION DEVIATION---------------------####
#Maximum elevation deviation over a range of spatial scales
####------------------------------local scale-------------------------------####
whitebox::wbt_max_elevation_deviation(
          dem = "C:/Users/kelto/Documents/repRCHrs/analysis/results/train_area/3dm_32482_5618_1_he_xyzirnc_ground_05.tif",
          out_mag = "C:/Users/kelto/Documents/repRCHrs/analysis/results/derivatives/52_WB_max_dev_local_magnitude05.tif",
          out_scale = "C:/Users/kelto/Documents/repRCHrs/analysis/results/derivatives/53_WB_max_dev_local_scale05.tif",
          min_scale = 1,
          max_scale= 10,
          step = 1,
          wd = NULL,
          verbose_mode = TRUE,
          compress_rasters = FALSE
)
####--------------------------------meso scale------------------------------####
whitebox::wbt_max_elevation_deviation(
          dem = "C:/Users/kelto/Documents/repRCHrs/analysis/results/train_area/3dm_32482_5618_1_he_xyzirnc_ground_05.tif",
          out_mag = "C:/Users/kelto/Documents/repRCHrs/analysis/results/derivatives/54_WB_max_dev_meso_magnitude05.tif",
          out_scale = "C:/Users/kelto/Documents/repRCHrs/analysis/results/derivatives/55_WB_max_dev_meso_scale05.tif",
          min_scale = 10,
          max_scale= 50,
          step = 1,
          wd = NULL,
          verbose_mode = TRUE,
          compress_rasters = FALSE
)
####-------------------------------broad scale------------------------------####
whitebox::wbt_max_elevation_deviation(
          dem = "C:/Users/kelto/Documents/repRCHrs/analysis/results/train_area/3dm_32482_5618_1_he_xyzirnc_ground_05.tif",
          out_mag = "C:/Users/kelto/Documents/repRCHrs/analysis/results/derivatives/56_WB_max_dev_broad_magnitude05.tif",
          out_scale = "C:/Users/kelto/Documents/repRCHrs/analysis/results/derivatives/57_WB_max_dev_broad_scale05.tif",
          min_scale = 50,
          max_scale= 100,
          step = 1,
          wd = NULL,
          verbose_mode = TRUE,
          compress_rasters = FALSE
)
####-------------------#58 MULTISCALE-TOPOGRAHPIC POSITION INDEX#-----------####
whitebox::wbt_multiscale_topographic_position_image(
  local = "C:/Users/kelto/Documents/repRCHrs/analysis/results/derivatives/52_WB_max_dev_local_magnitude05.tif",
  meso = "C:/Users/kelto/Documents/repRCHrs/analysis/results/derivatives/54_WB_max_dev_meso_magnitude05.tif",
  broad = "C:/Users/kelto/Documents/repRCHrs/analysis/results/derivatives/56_WB_max_dev_broad_magnitude05.tif",
  output = "C:/Users/kelto/Documents/repRCHrs/analysis/results/derivatives/58_WB_MTPI05.tif",
  lightness=1.2,
  wd = NULL,
  verbose_mode = TRUE,
  compress_rasters = FALSE
)
################################################################################
######################################USING GRASS###############################
####-------------------------#59 rgrass7:: LRM#-----------------------------####
################################################################################
#-------------------------------works on LINUX---------------------------------#
grass <- linkGRASS7(ver_select = TRUE)

link2GI::linkGRASS7(x = traindtm05,
                    gisdbase= "C:/Users/kelto/Documents/reRCHrs_REPO/GRASS",
                    location = "Init_project",
                    gisdbase_exist = FALSE)

#Loading/Importing the cropped raster in Grass
rgrass7::execGRASS('r.import',
                   input= "C:/Users/kelto/Documents/repRCHrs/analysis/results/train_area/3dm_32482_5618_1_he_xyzirnc_ground_05.tif",
                   output= "traindtm05_GRASS.tif@PERMANENT",
                   flags=c("overwrite"))

#---------------------------calculate a LOCAL RELIEF MODEL---------------------#
rgrass7::execGRASS(cmd = "r.local.relief",
                   flags = "overwrite",
                   input = "traindtm05_GRASS.tif@PERMANENT",
                   output = "traindtm_LRM.tif")

rgrass7::execGRASS(cmd = 'r.out.gdal',
                   flags=c("m","f", "t","overwrite","verbose"),
                   input="traindtm_LRM.tif@PERMANENT",
                   format="GTiff",
                   type="Float64",
                   output=paste0(path_analysis_results_derivatives,"59_traindtm_LRM.tif"))
################################################################################
################################USING SAGA ALGORITHMS###########################
####################################preparation#################################
#NB: you have to check your SAGA version and adapt certain functions and variable
#names! http://saga-gis.sourceforge.net/saga_tool_doc/
#-----------------write testdtm as a SAGA grid into the tmp folder-------------#
raster::writeRaster(traindtm05, paste0(path_tmp,"/traindtm05.sdat"),
                    overwrite = TRUE, NAflag = 0)
################################################################################
##########################TERRAIN ANALYSIS MORPHOMETRY MODULE###################
####--------------------#60 CONVERGENCE INDEX (SEARCH RADIUS)#--------------####
#after: Koethe, R. & Lehmeier, F. (1996)
#Radius: 3 cells; Difference: direction to the center cell
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 2,
                          param = list(ELEVATION=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       CONVERGENCE=paste0(path_tmp, "convind05.sgrd", sep=""),
                                       RADIUS=3, DW_WEIGHTING=0,
                                       SLOPE=1, DIFFERENCE=0),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
convind05 <- raster::raster(paste0(path_tmp, "convind05.sdat"))
crs(convind05) <- crs(traindtm05)
raster::writeRaster(convind05, paste0(path_analysis_results_derivatives,
                    "60_SAGA_convind05.tif"), overwrite = TRUE, NAflag = 0)
####----------------#61-65 RELATIVE HEIGHTS AND SLOPE POSITIONS#------------####
#after Boehner & Selige 2006
#H0=Slope Height; HU=Valley Depth; does not make much sense
#NH=Normalized Height; #SH = Standardized Height; MS= Mid-Slope Position
#W is the influence weight 0f catchment size on relative elevation
#The smaller T is the more maximum value is taken over into the cell; means a greater
#smoothing of the result; E controls the position of relative height maxima as a
#function of slope
#T=3 neighbours; the rest is default
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 14,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       HO=paste0(path_tmp, "sloh05.sgrd", sep=""),
                                       HU=paste0(path_tmp,"vld05.sgrd", sep=""),
                                       NH=paste0(path_tmp, "normh05.sgrid", sep=""),
                                       SH=paste0(path_tmp, "standh05.sgrid", sep=""),
                                       MS=paste0(path_tmp, "mspos05.sgrid", sep=""),
                                       W =0.5, T=3, E=2),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
sloh05 <- raster::raster(paste0(path_tmp, "sloh05.sdat"))
crs(sloh05) <- crs(traindtm05)
raster::writeRaster(sloh05, paste0(path_analysis_results_derivatives,
                    "61_SAGA_sloh05.tif"), overwrite = TRUE, NAflag = 0)
vld05 <- raster::raster(paste0(path_tmp, "vld05.sdat"))
crs(vld05) <- crs(traindtm05)
raster::writeRaster(vld05, paste0(path_analysis_results_derivatives,
                    "62_SAGA_vld05.tif"), overwrite = TRUE, NAflag = 0)
normh05 <- raster::raster(paste0(path_tmp, "normh05.sdat"))
crs(normh05) <- crs(traindtm05)
raster::writeRaster(normh05, paste0(path_analysis_results_derivatives,
                    "63_SAGA_normh05.tif"), overwrite = TRUE, NAflag = 0)
standh05 <- raster::raster(paste0(path_tmp, "standh05.sdat"))
crs(standh05) <- crs(traindtm05)
raster::writeRaster(standh05, paste0(path_analysis_results_derivatives,
                    "64_SAGA_standh05.tif"), overwrite = TRUE, NAflag = 0)
mspos05 <- raster::raster(paste0(path_tmp, "mspos05.sdat"))
crs(mspos05) <- crs(traindtm05)
raster::writeRaster(mspos05, paste0(path_analysis_results_derivatives,
                    "65_SAGA_mspos05.tif"), overwrite = TRUE, NAflag = 0)
####---------------------#66 TERRAIN RUGGEDNESS INDEX#----------------------####
#after Riley, S.J., De Gloria, S.D., Elliot, R. 1999;
#Radius 3 cells; the bigger the radius the more stronger the outline of the barrows
# but also more smoothed; Mode= square
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 16,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       TRI=paste0(path_tmp,"tri05.sgrd", sep=""),
                                       MODE=0, RADIUS=3),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
tri05 <- raster::raster(paste0(path_tmp, "tri05.sdat"))
crs(tri05) <- crs(traindtm05)
raster::writeRaster(tri05, paste0(path_analysis_results_derivatives,
                    "66_SAGA_tri05.tif"), overwrite = TRUE, NAflag = 0)
####---------------------#67 VECTOR RUGGEDNESS MEASURE#---------------------####
#after Sappington, J.M., Longshore, K.M., Thompson, D.B. 2007
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 17,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       VRM=paste0(path_tmp,"vrm05.sgrd", sep=""),
                                       MODE=0, RADIUS=5),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
vrm05 <- raster::raster(paste0(path_tmp,"vrm05.sdat"))
crs(vrm05) <- crs(traindtm05)
raster::writeRaster(vrm05, paste0(path_analysis_results_derivatives,
                    "67_SAGA_vrm05.tif"), overwrite = TRUE, NAflag = 0)
####-----------------------#68-69 TERRAIN SURFACE TEXTURE#------------------####
#Iwahashi & Pike (2007)
#EPSILON: flat area threshold = 0; SCALE:2
##method = resampling
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 20,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       TEXTURE=paste0(path_tmp,"txt_res05.sgrd", sep=""),
                                       EPSILON=0, SCALE=2, METHOD=1),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
txt05_res <- raster::raster(paste0(path_tmp, "txt_res05.sdat"))
crs(txt05_res) <- crs(traindtm05)
raster::writeRaster(txt05, paste0(path_analysis_results_derivatives,
                    "68_SAGA_txt05_res.tif"), overwrite = TRUE, NAflag = 0)

#method = counting cells
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 20,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       TEXTURE=paste0(path_tmp,"txt05.sgrd", sep=""),
                                       EPSILON=0, SCALE=2, METHOD=0),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
txt05 <- raster::raster(paste0(path_tmp, "txt05.sdat"))
crs(txt05) <- crs(traindtm05)
raster::writeRaster(txt05, paste0(path_analysis_results_derivatives,
                                  "69_SAGA_txt05.tif"), overwrite = TRUE, NAflag = 0)
####-----------------------#70 TERRAIN SURFACE CONVEXITY#-------------------####
#Iwahashi & Pike (2007)
#EPSILON: flat area threshold = 0; SCALE:2
#no difference between method = counting cells & resampling
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 21,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       CONVEXITY=paste0(path_tmp,"locconv05.sgrd", sep=""),
                                       KERNEL=0, TYPE=0, EPSILON=0, SCALE=2,
                                       METHOD=0, DW_WEIGHTING=0),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)

locconv05 <- raster::raster(paste0(path_tmp, "locconv05.sdat"))
crs(locconv05) <- crs(traindtm05)
raster::writeRaster(locconv05, paste0(path_analysis_results_derivatives,
                    "70_SAGA_locconv05.tif"), format= "GTiff", overwrite = TRUE, NAflag = 0)
####-----------------------#71-78 MORPHOMETRIC FEATURES#--------------------####
#Wood 1996 & Wood 2009
#TOL_SPLOE =0, up to 10° nothing changes
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 23,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       SLOPE=paste0(path_tmp,"slop05.sgrd", sep=""),
                                       ASPECT=paste0(path_tmp, "asp05.sgrd", sep=""),
                                       PROFC=paste0(path_tmp,"proc05.sgrd", sep=""),
                                       PLANC=paste0(path_tmp,"plac05.sgrd", sep=""),
                                       LONGC=paste0(path_tmp,"logc05.sgrd", sep=""),
                                       CROSC=paste0(path_tmp,"croc05.sgrd", sep=""),
                                       MAXIC=paste0(path_tmp,"maxc05.sgrd", sep=""),
                                       MINIC=paste0(path_tmp,"minc05.sgrd", sep=""),
                                       SIZE=2, TOL_SLOPE=0, CONSTRAIN=1),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
slop05 <- raster::raster(paste0(path_tmp, "slop05.sdat"))
crs(slop05) <- crs(traindtm05)
raster::writeRaster(slop05, paste0(path_analysis_results_derivatives,
                    "71_SAGA_slop05.tif"), overwrite = TRUE, NAflag = 0)
asp05 <- raster::raster(paste0(path_tmp, "asp05.sdat"))
crs(asp05) <- crs(traindtm05)
raster::writeRaster(asp05, paste0(path_analysis_results_derivatives,
                     "72_SAGA_asp05.tif"), overwrite = TRUE, NAflag = 0)
proc05 <- raster::raster(paste0(path_tmp, "proc05.sdat"))
crs(proc05) <- crs(traindtm05)
raster::writeRaster(proc05, paste0(path_analysis_results_derivatives,
                    "73_SAGA_proc05.tif"), overwrite = TRUE, NAflag = 0)
plac05 <- raster::raster(paste0(path_tmp, "plac05.sdat"))
crs(plac05) <- crs(traindtm05)
raster::writeRaster(plac05, paste0(path_analysis_results_derivatives,
                    "74_SAGA_plac05.tif"), overwrite = TRUE, NAflag = 0)
logc05 <- raster::raster(paste0(path_tmp, "logc05.sdat"))
crs(logc05) <- crs(traindtm05)
raster::writeRaster(logc05, paste0(path_analysis_results_derivatives,
                    "75_SAGA_logc05.tif"), overwrite = TRUE, NAflag = 0)
croc05 <- raster::raster(paste0(path_tmp, "croc05.sdat"))
crs(croc05) <- crs(traindtm05)
raster::writeRaster(croc05, paste0(path_analysis_results_derivatives,
                    "76_SAGA_croc05.tif"), overwrite = TRUE, NAflag = 0)
maxc05 <- raster::raster(paste0(path_tmp, "maxc05.sdat"))
crs(maxc05) <- crs(traindtm05)
raster::writeRaster(maxc05, paste0(path_analysis_results_derivatives,
                    "77_SAGA_maxc05.tif"), overwrite = TRUE, NAflag = 0)
minc05 <- raster::raster(paste0(path_tmp, "minc05.sdat"))
crs(minc05) <- crs(traindtm05)
raster::writeRaster(minc05, paste0(path_analysis_results_derivatives,
                    "78_SAGA_minc05.tif"), overwrite = TRUE, NAflag = 0)
####----------------------#79-83 UPSLOPE/DOWNSLOPE CURVATURE#- -------------####
#After Freemanx 1991 & Zevenbergen & Thorne 1987
#sadly does not enhance the barrow because they are too flat?
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 26,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       C_LOCAL=paste0(path_tmp, "clo05.sgrd", sep=""),
                                       C_UP=paste0(path_tmp,"cup05.sgrd", sep=""),
                                       C_UP_LOCAL=paste0(path_tmp,"cupl05.sgrd", sep=""),
                                       C_DOWN=paste0(path_tmp,"cdo05.sgrd", sep=""),
                                       C_DOWN_LOCAL=paste0(path_tmp,"cdl05.sgrd", sep="")),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
clo05 <- raster::raster(paste0(path_tmp, "clo05.sdat"))
crs(clo05) <- crs(traindtm05)
raster::writeRaster(clo05, paste0(path_analysis_results_derivatives,
                    "79_SAGA_clo05.tif"), overwrite = TRUE, NAflag = 0)
cup05 <- raster::raster(paste0(path_tmp, "cup05.sdat"))
crs(cup05) <- crs(traindtm05)
raster::writeRaster(cup05, paste0(path_analysis_results_derivatives,
                    "80_SAGA_cup05.tif"), overwrite = TRUE, NAflag = 0)
cupl05 <- raster::raster(paste0(path_tmp, "cupl05.sdat"))
crs(cupl05) <- crs(traindtm05)
raster::writeRaster(cupl05, paste0(path_analysis_results_derivatives,
                    "81_SAGA_cupl05.tif"), overwrite = TRUE, NAflag = 0)
cdo05 <- raster::raster(paste0(path_tmp,"cdo05.sdat"))
crs(cdo05) <- crs(traindtm05)
raster::writeRaster(cdo05, paste0(path_analysis_results_derivatives,
                    "82_SAGA_cdo05.tif"), overwrite = TRUE, NAflag = 0)
cdl05 <- raster::raster(paste0(path_tmp,"cdl05.sdat"))
crs(cdl05) <- crs(traindtm05)
raster::writeRaster(cdl05, paste0(path_analysis_results_derivatives,
                    "83_SAGA_cdl05.tif"), overwrite = TRUE, NAflag = 0)
####------------------------#84 WIND EXPOSITION INDEX#----------------------####
#After Boehner & Antonic 2009 & Gerlitz& Conrad&Böhner 2015
#everything detault, except MAXDIST = 0.1 m
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 27,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       EXPOSITION=paste0(path_tmp,"wind05.sgrd", sep=""),
                                       MAXDIST=0.1, STEP=15, OLDVER=0,
                                       ACCEL=1.5, PYRAMIDS=0),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
wind05 <- raster::raster(paste0(path_tmp, "wind05.sdat"))
crs(wind05) <- crs(traindtm05)
raster::writeRaster(wind05, paste0(path_analysis_results_derivatives,
                    "84_SAGA_wind05.tif"), overwrite = TRUE, NAflag = 0)

####--------------#85-89 MULTISCALE TOPOGRAPHIC POSITION INDEX--------------####
#Topographic Position Index (TPI) calculation as proposed by Guisan et al. (1999)
#the higher the max scale, the better defined are the barrows
#----------------------#SCALE_MIN=1, SCALE_MAX=20, SCALE_NUM=2#----------------#
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 28,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       TPI=paste0(path_tmp,"mtpi05.sgrd", sep=""),
                                       SCALE_MIN=1, SCALE_MAX=20, SCALE_NUM=2),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
mtpi05 <- raster::raster(paste0(path_tmp, "mtpi05.sdat"))
crs(mtpi05) <- crs(traindtm05)
raster::writeRaster(mtpi05, paste0(path_analysis_results_derivatives,
                    "85_SAGA_mtpi05.tif"), overwrite = TRUE, NAflag = 0)
#--------------------#b) SCALE_MIN=1, SCALE_MAX=20, SCALE_NUM=5#---------------#
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 28,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       TPI=paste0(path_tmp,"mtpi05b.sgrd", sep=""),
                                       SCALE_MIN=1, SCALE_MAX=20, SCALE_NUM=5),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
mtpi05b <- raster::raster(paste0(path_tmp, "mtpi05b.sdat"))
crs(mtpi05b) <- crs(traindtm05)
raster::writeRaster(mtpi05b, paste0(path_analysis_results_derivatives,
                    "86_SAGA_mtpi05b.tif"), overwrite = TRUE, NAflag = 0)
#-------------------#c) SCALE_MIN=1, SCALE_MAX=20, SCALE_NUM=10#---------------#
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 28,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       TPI=paste0(path_tmp,"mtpi05c.sgrd", sep=""),
                                       SCALE_MIN=1, SCALE_MAX=20, SCALE_NUM=10),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
mtpi05c <- raster::raster(paste0(path_tmp, "mtpi05c.sdat"))
crs(mtpi05c) <- crs(traindtm05)
raster::writeRaster(mtpi05c, paste0(path_analysis_results_derivatives,
                    "87_SAGA_mtpi05c.tif"), overwrite = TRUE, NAflag = 0)
#there is minor difference when doubling the number of scales
#--------------------#d) SCALE_MIN=1, SCALE_MAX=30, SCALE_NUM=2#---------------#
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 28,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       TPI=paste0(path_tmp,"mtpi05d.sgrd", sep=""),
                                       SCALE_MIN=1, SCALE_MAX=30, SCALE_NUM=2),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
mtpi05d <- raster::raster(paste0(path_tmp, "mtpi05d.sdat"))
crs(mtpi05d) <- crs(traindtm05)
raster::writeRaster(mtpi05d, paste0(path_analysis_results_derivatives,
                    "88_SAGA_mtpi05d.tif"), overwrite = TRUE, NAflag = 0)
#--------------------#e) SCALE_MIN=1, SCALE_MAX=30, SCALE_NUM=5#---------------#
RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 28,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       TPI=paste0(path_tmp,"mtpi05e.sgrd", sep=""),
                                       SCALE_MIN=1, SCALE_MAX=30, SCALE_NUM=5),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
mtpi05e <- raster::raster(paste0(path_tmp, "mtpi05e.sdat"))
crs(mtpi05e) <- crs(traindtm05)
raster::writeRaster(mtpi05e, paste0(path_analysis_results_derivatives,
                    "89_SAGA_mtpi05e.tif"), overwrite = TRUE, NAflag = 0)

#the best is d) because it enhances even the barrow in the field and smoothes the
#other objects which could interfere with the barrows
################################################################################
#################################HYDROLOGY MODULE###############################
####------------------------#90 SAGA WETNESS INDEX#------------------####
RSAGA::rsaga.geoprocessor(lib = "ta_hydrology", module = 15,
                          param = list(DEM=paste(path_tmp,"traindtm05.sgrd", sep=""),
                                       TWI=paste(path_tmp,"swi05.sgrd", sep="")),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
swi05 <- raster::raster(paste0(path_tmp, "swi05.sdat"))
crs(swi05) <- crs(traindtm05)
raster::writeRaster(swi05, paste0(path_analysis_results_derivatives, "90_SAGA_swi05.tif"),
                    overwrite = TRUE, NAflag = 0)
################################################################################
#################################LIGHTNING MODULE###############################
####--------------------------#91 NEGATIVE OPENNESS#------------------------####
RSAGA::rsaga.geoprocessor(lib = "ta_lighting", module = 5,
                          param = list(DEM=paste0(path_tmp,"traindtm05.sgrd", sep=""),
                                       NEG=paste0(path_tmp,"nego05.sgrd", sep=""),
                                       POS=paste0(path_tmp,"poso05.sgrd", sep=""),
                                       RADIUS=100, METHOD=0, DLEVEL=3, NDIRS=8),
                          show.output.on.console = TRUE, invisible = TRUE,
                          env = env)
nego05 <- raster::raster(paste0(path_tmp, "nego05.sdat"))
crs(nego05) <- crs(traindtm05)
raster::writeRaster(nego05, paste0(path_analysis_results_derivatives, "91_SAGA_nego05.tif"),
                    overwrite = TRUE, NAflag = 0)
