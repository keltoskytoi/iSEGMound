################################################################################
####------------------------------#SHORTCUTS#-------------------------------####
#Because the the LAZ files from 2009/10 are appr. 8 GB, they had to be moved
#outside of the project
lsLIDAR_2009_10 <- list.files(("C:/Users/kelto/Documents/reRCHrs_REPO/LiDAR_2009_10"),
                        pattern = glob2rx("*.laz"), full.names = TRUE)

#define points for cross section:
point1 <- c(478000, 5616000) #xy
point2 <- c(478500, 5616500) #xy
point3 <- c(478500, 5616500) #xy
point4 <- c(479000, 5617000) #xy

################################################################################
####--------------------------#READ 1 LAZ FILE#-----------------------------####
#read data####
LIDR_200910_1 <- lidR::readLAS(lsLIDAR_2009_10[1])
#Warnmeldung:
#Invalid data: ScanAngleRank greater than 90 degrees
print(LIDR_200910_1)
#class        : LAS (v1.3 format 1)
#memory       : 780.3 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : NA
#area         : 1 kunits²
#points       : 10.23 million points
#density      : 10.23 points/units²

#assign projection#####
sp::proj4string(LIDR_200910_1) <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"

#print again#
lidR::print(LIDR_200910_1)
#class        : LAS (v1.3 format 1)
#memory       : 780.3 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area         : 1 km²
#points       : 10.23 million points
#density      : 10.23 points/m²

#summary####
lidR::summary(LIDR_200910_1)
#class        : LAS (v1.3 format 1)
#memory       : 780.3 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area         : 1 km²
#points       : 10.23 million points
#density      : 10.23 points/m²
#File signature:           LASF
#File source ID:           0
#Global encoding:
#- GPS Time Type: GPS Week Time
#- Synthetic Return Numbers: no
#- Well Know Text: CRS is GeoTIFF
#- Aggregate Model: false
#Project ID - GUID:        00000000-0000-0000-0000-000000000000
#Version:                  1.3
#System identifier:        LAStools (c) by rapidlasso GmbH
#Generating software:      lasmerge (version 161114)
#File creation d/y:        122/2016
#header size:              235
#Offset to point data:     235
#Num. var. length record:  0
#Point data format:        1
#Point data record length: 28
#Num. of point records:    10227004
#Num. of points by return: 8999985 949108 240884 34535 2423
#Scale factor X Y Z:       0.001 0.001 0.001
#Offset X Y Z:             478000 5616942 100
#min X Y Z:                478000 5616000 166
#max X Y Z:                479000 5617000 264.9
#Variable length records:  void

#plot in pointcloud viewer
#plot(LIDR_2014_1, bg = "green", color = "Z",colorPalette = terrain.colors(256),backend="pcv")

#check data quality####
#before getting started it is always good to check the data quality

lidR::las_check(LIDR_200910_1)
#⚠ 202 points are duplicated and share XYZ coordinates with other points
#⚠ There were 2370 generated ground points. Some X Y Z coordinates were repeated.
#⚠ There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates.
#⚠ 'ScanDirectionFlag' attribute is not populated.
#⚠ A proj4string found but no CRS in the header.
#- Checking normalization... no

################################################################################
#set the number of threads/cores lidR should use
getDTthreads() #6
lidR::set_lidr_threads(4)
################################################################################
####------------------#1.(RE)CLASSIFICATION OF GROUND POINTS#---------------####
#get to know the pointcloud####

#LAS stores x,y,z for each point + many other information=attributes and this
#can take a lot of memory from the PC

# 'select' enables to choose between attributes/columns
names(LIDR_200910_1@data)
#[1] "X"                 "Y"                 "Z"                 "gpstime"
#[5] "Intensity"         "ReturnNumber"      "NumberOfReturns"   "ScanDirectionFlag"
#[9] "EdgeOfFlightline"  "Classification"    "Synthetic_flag"    "Keypoint_flag"
#[13] "Withheld_flag"     "ScanAngleRank"     "UserData"          "PointSourceID"
#queries are: t - gpstime, a - scan angle, i - intensity, n - number of returns,
#r - return number, c - classification, s - synthetic flag, k - keypoint flag,
#w - withheld flag, o - overlap flag (format 6+), u - user data, p - point source ID,
#e - edge of flight line flag, d - direction of scan flag
#default is xyz

#'filter' enables to choose between the rows/points; the filter options can be
#accessed by: read.las(filter = "-help")

#note: when using the select and filter arguments with readLAS, this allows to filter while
#reading the file thus saving memory and computation time - it the same as when reading
#the las file and then filtering the pint cloud

#read a selected pointcloud: x,y,z, return number and number of returns, intensity, classification
LIDR_200910_1_xyzirnc <- lidR::readLAS(lsLIDAR_2009_10[1], select = "xyzirnc")

print(LIDR_200910_1_xyzirnc) #no CRS

#assign projection
sp::proj4string(LIDR_200910_1_xyzirnc) <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"

lidR::print(LIDR_200910_1_xyzirnc)
#class        : LAS (v1.3 format 1)
#memory       : 390.1 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area         : 1 km²
#points       : 10.23 million points
#density      : 10.23 points/m²

#####-----------------------#A) GROUND CLASSIFICATION#----------------------####
#i LIDR_2014_1_ground
LIDR_200910_1_ground <- lidR::readLAS(lsLIDAR_2009_10[1], select = "xyzirnc", filter ="keep_class 2")

#assign projection
sp::proj4string(LIDR_200910_1_ground) <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"

print(LIDR_200910_1_ground)
#class        : LAS (v1.3 format 1)
#memory       : 390.1 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area         : 1 km²
#points       : 10.23 million points
#density      : 10.23 points/m²

LIDR_200910_1_ground_clipped <- clip_transect(LIDR_200910_1_ground, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_ground_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_ground_clipped2 <- clip_transect(LIDR_200910_1_ground, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_ground_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_ground_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_ground_clipped2, colour_by = factor(Classification))
################################################################################
####-----------------#B) PROGRESSIVE MORPHOLOGICAL FILTER#------------------####
          #based on Zhang et al 2013, but applied to a point cloud

#iia LIDR_2014_1_xyzirnc_pmf####
#first let's test a simple morphological filter (see LidRbook)####
LIDR_200910_1_xyzirnc_pmf <- lidR::classify_ground(LIDR_200910_1_xyzirnc, algorithm = pmf(ws = 5, th = 3))
#Original dataset already contains 7718079 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_pmf_clipped <- clip_transect(LIDR_200910_1_xyzirnc_pmf, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_pmf_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_pmf, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_pmf_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_pmf_clipped2, colour_by = factor(Classification))

#th1####
LIDR_200910_1_xyzirnc_pmf_th1 <- lidR::classify_ground(LIDR_200910_1_xyzirnc, algorithm = pmf(ws = 5, th = 1))
#Original dataset already contains 7718079 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_pmf_th1_clipped <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th1, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th1_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_pmf_th1_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th1, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th1_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_pmf_th1_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_pmf_th1_clipped2, colour_by = factor(Classification))

#th05####
LIDR_200910_1_xyzirnc_pmf_th05 <- lidR::classify_ground(LIDR_200910_1_xyzirnc, algorithm = pmf(ws = 5, th = 0.5))
#Original dataset already contains 7718079 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_pmf_th05_clipped <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th05, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th05_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_pmf_th05_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th05, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th05_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_pmf_th05_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_pmf_th05_clipped2, colour_by = factor(Classification))

#th04####
LIDR_200910_1_xyzirnc_pmf_th04 <- lidR::classify_ground(LIDR_200910_1_xyzirnc, algorithm = pmf(ws = 5, th = 0.4))
#Original dataset already contains 7718079 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

print(LIDR_200910_1_xyzirnc_pmf_th04)

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_pmf_th04_clipped <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th04, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th04_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_pmf_th04_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th04, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th04_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_pmf_th04_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_pmf_th04_clipped2, colour_by = factor(Classification))


#th03####
LIDR_200910_1_xyzirnc_pmf_th03 <- lidR::classify_ground(LIDR_200910_1_xyzirnc, algorithm = pmf(ws = 5, th = 0.3))
#Original dataset already contains 7718079 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_pmf_th03_clipped <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th03, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th03_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_pmf_th03_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th03, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th03_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_pmf_th03_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_pmf_th03_clipped2, colour_by = factor(Classification))

#th01####
LIDR_200910_1_xyzirnc_pmf_th01 <- lidR::classify_ground(LIDR_200910_1_xyzirnc, algorithm = pmf(ws = 5, th = 0.1))
#Original dataset already contains 7718079 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_pmf_th01_clipped <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th01, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th01_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_pmf_th01_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th01, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th01_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_pmf_th01_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_pmf_th01_clipped2, colour_by = factor(Classification))

#th005####
LIDR_200910_1_xyzirnc_pmf_th005 <- lidR::classify_ground(LIDR_200910_1_xyzirnc, algorithm = pmf(ws = 5, th = 0.05))
#Original dataset already contains 7718079 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_pmf_th005_clipped <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th005, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th005_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_pmf_th005_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_pmf_th005, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_pmf_th01_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_pmf_th005_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_pmf_th005_clipped2, colour_by = factor(Classification))

################################################################################
####------------------------#CLOTH SIMULATION FUNCTION#---------------------####
                            #based on Zhang et al 2016
#default settings of csf####
LIDR_200910_1_xyzirnc_csf <- lidR::classify_ground(LIDR_200910_1_xyzirnc, algorithm = csf())
#Original dataset already contains 6673368 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_csf_clipped <- clip_transect(LIDR_200910LIDR_200910_1_xyzirnc_csf, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_csf_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_csf_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_csf, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_csf_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_csf_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_csf_clipped2, colour_by = factor(Classification))

#changing the settings of csf a bit 1 - csf2####
csf_1 <- csf(sloop_smooth = TRUE, class_threshold = 0.5, cloth_resolution = 0.5, rigidness = 1, iterations = 500, time_step = 0.65)
LIDR_200910_1_xyzirnc_csf2 <- lidR::classify_ground(LIDR_200910_1_xyzirnc, csf_1)
#Original dataset already contains 6673368 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_csf2_clipped <- clip_transect(LIDR_200910_1_xyzirnc_csf2, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_csf2_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_csf2_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_csf2, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_csf2_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_csf2_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_csf2_clipped2, colour_by = factor(Classification))

#changing the settings of csf a bit 2 - csf3####
csf_2 <- csf(sloop_smooth = TRUE, class_threshold = 0.5, cloth_resolution = 0.5, rigidness = 2, iterations = 500, time_step = 0.65)
LIDR_200910_1_xyzirnc_csf3 <- lidR::classify_ground(LIDR_200910_1_xyzirnc, csf_2)
##Original dataset already contains 6673368 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_csf3_clipped <- clip_transect(LIDR_200910_1_xyzirnc_csf3, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_csf3_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_csf3_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_csf3, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_csf3_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_csf3_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_csf3_clipped2, colour_by = factor(Classification))

#csf4####
csf_3 <- csf(sloop_smooth = TRUE, class_threshold = 0.2, cloth_resolution = 0.2, rigidness = 2, iterations = 500, time_step = 0.65)
LIDR_200910_1_xyzirnc_csf4 <- lidR::classify_ground(LIDR_200910_1_xyzirnc, csf_3)
##Original dataset already contains 6673368 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#make a cross section and check the classification results:
LIDR_200910_1_xyzirnc_csf4_clipped <- clip_transect(LIDR_200910_1_xyzirnc_csf4, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_csf4_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_1_xyzirnc_csf4_clipped2 <- clip_transect(LIDR_200910_1_xyzirnc_csf4, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_1_xyzirnc_csf3_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_1_xyzirnc_csf4_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_1_xyzirnc_csf4_clipped2, colour_by = factor(Classification))


################################################################################
####-------------------------#2.DTM GENERATION#-----------------------------####
#one question is still lingering around: which resolution should be used?
#well, because quite huge data sets are going to be used, the tiles should not be too big
#in the following different resolutions have been computed and even if one thrives to
#work with VHR resolution, the question is: is it worth it? do we see more of a 3 m
#object in a 5 cm resolution image than in a 10 cm one? For comparison:
#a 5 cm resolution DTM is 1 GB
#a 10 cm resolution raster is 300 MB
#in the 2014 data set there are 209 tiles (~ 8 GB)
#in the 2018 data set are 45 tiles (~ 160 GB)
################################################################################
####-------------------#A.TRIANGULAR IRREGULAR NETWORK (TIN)#----------------####
####---------------------#using the point classification#-------------------####
#0.5m####
LIDR_200910_1_ground_tin05 <- lidR::grid_terrain(LIDR_200910_1_ground, res = 0.5, algorithm = tin())
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_ground_tin05)
#class      : RasterLayer
#dimensions : 10000, 10000, 1e+08  (nrow, ncol, ncell)
#resolution : 0.1, 0.1  (x, y)
#extent     : 478000, 479000, 5616000, 5617000  (xmin, xmax, ymin, ymax)
#crs        : +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#source     : memory
#names      : Z
#values     : 166.088, 237.402  (min, max)

#write/export as raster
raster::writeRaster(LIDR_200910_1_ground_tin05, file.path(path_tests,
                    "dtm_200910_1_xyzirnc_ground_tin_05.tif"), format = "GTiff", overwrite = TRUE)

#0.2m####
LIDR_200910_1_ground_tin02 <- lidR::grid_terrain(LIDR_200910_1_ground, res = 0.2, algorithm = tin())
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_ground_tin02)
#class      : RasterLayer
#dimensions : 10000, 10000, 1e+08  (nrow, ncol, ncell)
#resolution : 0.1, 0.1  (x, y)
#extent     : 478000, 479000, 5616000, 5617000  (xmin, xmax, ymin, ymax)
#crs        : +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#source     : memory
#names      : Z
#values     : 166.088, 237.402  (min, max)

#write/export as raster
raster::writeRaster(LIDR_200910_1_ground_tin02, file.path(path_tests,
                    "dtm_200910_1_xyzirnc_ground_tin_02.tif"), format = "GTiff", overwrite = TRUE)

#0.1m####
LIDR_200910_1_ground_tin01 <- lidR::grid_terrain(LIDR_200910_1_ground, res = 0.1, algorithm = tin())
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_ground_tin01)
#class      : RasterLayer
#dimensions : 10000, 10000, 1e+08  (nrow, ncol, ncell)
#resolution : 0.1, 0.1  (x, y)
#extent     : 478000, 479000, 5616000, 5617000  (xmin, xmax, ymin, ymax)
#crs        : +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#source     : memory
#names      : Z
#values     : 166.088, 237.402  (min, max)

#write/export as raster
raster::writeRaster(LIDR_200910_1_ground_tin01, file.path(path_tests,
                    "dtm_200910_1_xyzirnc_ground_tin_01.tif"), format = "GTiff", overwrite = TRUE)

#0.05m####
LIDR_200910_1_ground_tin005 <- lidR::grid_terrain(LIDR_200910_1_ground, res = 0.05, algorithm = tin())
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_ground_tin005)

#write/export as raster
raster::writeRaster(LIDR_200910_1_ground_tin005, file.path(path_tests,
                    "dtm_200910_1_xyzirnc_ground_tin_005.tif"), format = "GTiff", overwrite = TRUE)

####---------------------#Progressive Morphological Filter#-----------------####
#0.5 m####
LIDR_200910_1_xyzirnc_pmf_tin05 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf, res = 0.5, algorithm = tin())
#Warning messages:
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_tin05)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_pmf_tin05, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_tin_05.tif"), format = "GTiff", overwrite = TRUE)

#0.2 m####
LIDR_200910_1_xyzirnc_pmf_tin02 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf, res = 0.2, algorithm = tin())
#Warning messages:
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_tin02)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_pmf_tin02, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_tin_02.tif"), format = "GTiff", overwrite = TRUE)

#0.1 m####
LIDR_200910_1_xyzirnc_pmf_tin01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf, res = 0.1, algorithm = tin())
#Warning messages:
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_tin01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_pmf_tin01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_tin_01.tif"), overwrite = TRUE)

#0.05m####
LIDR_200910_1_xyzirnc_pmf_dtm_tin005 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf, res = 0.05, algorithm = tin())
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_dtm_tin005)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_pmf_dtm_tin005, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_tin_005.tif"), format = "GTiff", overwrite = TRUE)


#0.1 m - th1####
LIDR_200910_1_xyzirnc_pmf_th1_tin01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th1, res = 0.1, algorithm = tin())
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_th1_tin01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_pmf_th1_tin01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th1_tin01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 m - th05####
LIDR_200910_1_xyzirnc_pmf_th05_tin01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th05, res = 0.1, algorithm = tin())
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_th05_tin01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_pmf_th05_tin01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th05_tin01.tif"), format = "GTiff" ,overwrite = TRUE)

#0.1 m - th04####
LIDR_200910_1_xyzirnc_pmf_th04_tin01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th04, res = 0.1, algorithm = tin())
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_th04_tin01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_pmf_th04_tin01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th04_tin01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 m - th03####
LIDR_200910_1_xyzirnc_pmf_th03_tin01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th03, res = 0.1, algorithm = tin())
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_th03_tin01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_pmf_th03_tin01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th03_tin01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 m - th01####
LIDR_200910_1_xyzirnc_pmf_th01_tin01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th01, res = 0.1, algorithm = tin())
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_th01_tin01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_pmf_th01_tin01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th01_tin01.tif"), format = "GTiff" , overwrite = TRUE)

#0.1 m - th005####
LIDR_200910_1_xyzirnc_pmf_th005_tin01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th005, res = 0.1, algorithm = tin())
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_th005_tin01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_pmf_th005_tin01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th005_tin01.tif"), format = "GTiff" , overwrite = TRUE)

#####------------------------#Cloth Simulation Function#--------------------####
#0.1 m csf####
LIDR_200910_1_xyzirnc_csf_tin01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf, res = 0.1, algorithm = tin())
#Warning messages:
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf_tin01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf_tin01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf_tin_01.tif"), format = "GTiff" , overwrite = TRUE)

#0.1 m csf2####
LIDR_200910_1_xyzirnc_csf2_tin01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf2, res = 0.1, algorithm = tin())
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2321 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf2_tin01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf2_tin01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf2_tin_01.tif"), format  = "GTiff", overwrite = TRUE)

#0.1 m csf3####
LIDR_200910_1_xyzirnc_csf3_tin01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf3, res = 0.1, algorithm = tin())

#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf3_tin01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf3_tin01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf3_tin_01.tif"), format = "GTiff" , overwrite = TRUE)

################################################################################
####----------------------#B.INVERT DISTANCE WEIGHING#----------------------####
####---------------------#USING THE POINT CLASSIFICATION#-------------------####
#0.1 + default settings####
LIDR_200910_1_ground_idw01 <- lidR::grid_terrain(LIDR_200910_1_ground, res= 0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_ground_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_ground_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_ground_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_ground_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_ground, res= 0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_ground_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_ground_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_ground_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_ground_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_ground, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_ground_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_ground_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_ground_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + double of the default settings####
LIDR_200910_1_ground_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_ground, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#3: In UseMethod("depth"): nicht anwendbare Methode für 'depth' auf Objekt der Klasse "NULL" angewendet

#check raster
print(LIDR_200910_1_ground_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_ground_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_ground_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_ground_idw01_5 <- lidR::grid_terrain(LIDR_200910_1_ground, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_ground_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_ground_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_ground_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)

####---------------------#PROGRESSIVE MORPHOLOGICAl FILTER#-----------------####
#0.1 + default settings####
LIDR_200910_1_pmf_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_pmf_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_idw01, paste0(path_tests,
                     "dtm_200910_1_xyzirnc_pmf_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_pmf_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf, res= 0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_pmf_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + double of the default settings####
LIDR_200910_1_pmf_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_pmf_idw01_5 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)

#### -------------------------#LIDR_2014_1_pmf_th1#-------------------------####
#0.1 + default settings####
LIDR_200910_1_pmf_th1_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th1, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th1_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th1_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th1_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_pmf_th1_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th1, res= 0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th1_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th1_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th1_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_pmf_th1_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th1, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th1_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_pmf_th1_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th1_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + double of the default settings####
LIDR_200910_1_pmf_th1_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th1, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th1_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th1_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th1_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_pmf_th1_idw01_5 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th1, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th1_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th1_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th1_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)

####--------------------------#LIDR_2014_1_pmf_th05#------------------------####
#0.1 + default settings####
LIDR_200910_1_pmf_th05_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th05, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th05_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th05_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th05_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_pmf_th05_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th05, res= 0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th05_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th05_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th05_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_pmf_th05_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th05, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th05_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th05_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th05_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + double of the default settings####
LIDR_200910_1_pmf_th05_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th05, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th05_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th05_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th05_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_pmf_th05_idw01_5 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th05, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th05_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th05_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th05_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)
####--------------------------#LIDR_2014_1_pmf_th04#------------------------####
#0.1 + default settings####
LIDR_200910_1_pmf_th04_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th04, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th04_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th04_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th04_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_pmf_th04_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th04, res= 0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th04_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th04_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th04_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_pmf_th04_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th04, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th04_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th04_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th04_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + double of the default settings####
LIDR_200910_1_pmf_th04_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th04, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th04_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th04_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th04_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_pmf_th04_idw01_5 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th04, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 246 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 1815 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#check raster
print(LIDR_200910_1_pmf_th04_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th04_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th04_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)


####--------------------------#LIDR_2014_1_pmf_th03#------------------------####
#0.1 + default settings####
LIDR_200910_1_pmf_th03_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th03, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th03_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th03_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th03_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_pmf_th03_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th03, res= 0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th03_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th03_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th03_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_pmf_th03_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th03, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th03_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th03_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th03_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + double of the default settings####
LIDR_200910_1_pmf_th03_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th03, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th03_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th03_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th03_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_pmf_th03_idw01_5 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th03, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 244 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 1782 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th03_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th03_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th03_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)

####--------------------------#LIDR_2014_1_pmf_th01#------------------------####
#0.1 + default settings####
LIDR_200910_1_pmf_th01_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th01, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th01_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th01_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th01_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_pmf_th01_idw01_2 <- lidR::grid_terrain(LLIDR_200910_1_xyzirnc_pmf_th01, res= 0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th01_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th01_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th01_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_pmf_th01_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th01, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th01_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th01_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th01_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + double of the default settings####
LIDR_200910_1_pmf_th01_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th01, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th01_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th01_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th01_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_pmf_th01_idw01_5 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th01, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th01_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th01_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th01_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)

####--------------------------#LIDR_2014_1_pmf_th005#-----------------------####
#0.1 + default settings####
LIDR_200910_1_pmf_th005_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th005, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th005_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th005_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th005_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_pmf_th005_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th005, res= 0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th005_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th005_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th005_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_pmf_th005_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th005, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th005_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th005_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th005_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + double of the default settings####
LIDR_200910_1_pmf_th005_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th005, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th005_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th005_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th005_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_pmf_th005_idw01_5 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_pmf_th005, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 387 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2425 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_pmf_th005_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_pmf_th005_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_pmf_th005_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)

####-----------------------#CLOTH SIMULATION FUNCTION#----------------------####
####----------------------------------#csf#---------------------------------####
#0.1 + default settings####
LIDR_200910_1_csf_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_csf_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_csf_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_csf_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf, res=0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_csf_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_csf_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_csf_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_csf_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_csf_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with double of the default settings####
LIDR_200910_1_csf_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_csf_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_csf_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_csf_idw01_5 <- grid_terrain(LIDR_200910_1_xyzirnc_csf, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_csf_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_csf_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)

####------------------------------------#csf2#------------------------------####
#0.1 + default settings####
LIDR_200910_1_csf2_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf2, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2321 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_csf2_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_csf2_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf2_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_csf2_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf2, res=0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2321 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_csf2_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_csf2_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf2_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_csf2_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf2, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2321 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_csf2_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_csf2_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf2_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with double of the default settings####
LIDR_200910_1_csf2_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf2, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2321 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_csf2_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_csf2_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf2_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_csf2_idw01_5 <- grid_terrain(LIDR_200910_1_xyzirnc_csf2, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2321 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_csf2_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_csf2_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf2_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)

####-----------------------------------#csf3#-------------------------------####
#0.1 + default settings####
LIDR_200910_1_xyzirnc_csf3_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf3, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf3_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf3_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf3_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_xyzirnc_csf3_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf3, res=0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf3_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf3_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf3_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_xyzirnc_csf3_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf3, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf3_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf3_idw01_3, paste0(path_tests,
                    "dtm_2010910_1_xyzirnc_csf3_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with double of the default settings####
LIDR_200910_1_xyzirnc_csf3_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf3, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf3_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf3_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf3_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_xyzirnc_csf3_idw01_5 <- grid_terrain(LIDR_200910_1_xyzirnc_csf3, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

####-----------------------------------#csf4#-------------------------------####
#0.1 + default settings####
LIDR_200910_1_xyzirnc_csf4_idw01 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf4, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf4_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf4_idw01, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf4_idw_01.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_200910_1_xyzirnc_csf4_idw01_2 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf4, res=0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf4_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf4_idw01_2, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf4_idw_01_2.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_200910_1_xyzirnc_csf4_idw01_3 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf4, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf4_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf4_idw01_3, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf4_idw_01_3.tif"), format = "GTiff", overwrite = TRUE)

#0.1 with double of the default settings####
LIDR_200910_1_xyzirnc_csf4_idw01_4 <- lidR::grid_terrain(LIDR_200910_1_xyzirnc_csf4, res=0.1, algorithm = knnidw(k = 20L, p = 4, rmax = 50))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf4_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf4_idw01_4, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf4_idw_01_4.tif"), format = "GTiff", overwrite = TRUE)

#0.1 + multiple and half of the default settings####
LIDR_200910_1_xyzirnc_csf4_idw01_5 <- grid_terrain(LIDR_200910_1_xyzirnc_csf4, res=0.1, algorithm = knnidw(k = 50L, p = 6, rmax = 25))
#1: There were 378 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2322 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_1_xyzirnc_csf4_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_200910_1_xyzirnc_csf4_idw01_5, paste0(path_tests,
                    "dtm_200910_1_xyzirnc_csf4_idw_01_5.tif"), format = "GTiff", overwrite = TRUE)

################################################################################
####--------------------#Comparing the DTM results#-------------------------####
#The test DTMs have been compared visually in QGIS. Keeping the aim of this thesis:
#the terrain should be as accurate as possible BUT there should be as minimal
#disturbances and artifacts/noise in the texture of the terrain as possible not to compete
#with the archaeological objects to be detected. Thus the existing ground
#classification, pmf and csf was compared with TIN and IDW interpolation and
#it has been found that the ground classification + IDW gives the smoothest surface.
#Kriging is taking way too long and DTM generation is only a tool not the aim of
#this thesis.

#####--------------------------#TEST TILE 79#-------------------------------####
LIDR_200910_79_xyzirnc <- lidR::readLAS(lsLIDAR_2009_10[79], select = "xyzirnc")
print(LIDR_200910_79_xyzirnc) #no CRS
#assign projection
sp::proj4string(LIDR_200910_79_xyzirnc) <- sp::CRS("+init=epsg:25832")
lidR::print(LIDR_200910_79_xyzirnc)
print(LIDR_200910_79_xyzirnc)
#class        : LAS (v1.3 format 1)
#memory       : 494 Mb
#extent       : 482000, 483000, 5618000, 5619000 (xmin, xmax, ymin, ymax)
#coord. ref.  : ETRS89 / UTM zone 32N
#area         : 1 km²
#points       : 12.95 million points
#density      : 12.95 points/m²

LIDR_200910_79_xyzirnc_pmf_th04 <- lidR::classify_ground(LIDR_200910_79_xyzirnc, algorithm = pmf(ws = 5, th = 0.4))
#Original dataset already contains 7208709 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#define points for cross section:
point3 <- c(482673, 5618847) #xy
point4 <- c(482669, 5618720) #xy
point5 <- c(482588, 5618768) #xy
point6 <- c(482724, 5618755) #xy

#make a cross section and check the classification results:
LIDR_200910_79_xyzirnc_pmf_th04_clipped <- clip_transect(LIDR_200910_79_xyzirnc_pmf_th04, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_200910_79_xyzirnc_pmf_th04_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_200910_79_xyzirnc_pmf_th04_clipped2 <- clip_transect(LIDR_200910_79_xyzirnc_pmf_th04, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_200910_79_xyzirnc_pmf_th04_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_200910_79_xyzirnc_pmf_th04_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_200910_79_xyzirnc_pmf_th04_clipped2, colour_by = factor(Classification))

LIDR_200910_79_pmf_th04_idw01 <- lidR::grid_terrain(LIDR_200910_79_xyzirnc_pmf_th04, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 266 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 1839 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_200910_79_pmf_th04_idw01)

#write/export as raster
raster::writeRaster(LIDR_200910_79_pmf_th04_idw01, paste0(path_tests,
                    "dtm_200910_79_xyzirnc_pmf_th04_idw_01.tif"), format = "GTiff", overwrite = TRUE)
