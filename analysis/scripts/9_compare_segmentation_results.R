################################################################################
####-------------#1.READ MOUNDS DOBIAT 1994 IN THE TRAIN AREA#--------------####
all_train_mounds<-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "all_train_mounds.shp"))
mounds_5_35 <-readOGR(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "mounds_5_35.shp"))
crs(all_train_mounds) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
####--------------------------#1.READ MOUND RESULTS#------------------------####
iSEG_WS <-readOGR(paste0(path_analysis_results_5a_iSEG05_WS, "iSEG_WS.shp"))
iSEG_RG <-readOGR(paste0(path_analysis_results_5c_iSEG05_RG, "iSEG_RG.shp"))
crs(iSEG_WS) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
crs(iSEG_RG) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
iSEG_mtpi_WS <-readOGR(paste0(path_analysis_results_5b_iSEG05_mtpi_WS, "iSEG_mtpi_WS.shp"))
iSEG_mtpi_RG <-readOGR(paste0(path_analysis_results_5d_iSEG05_mtpi_RG, "iSEG_mtpi_RG.shp"))
crs(iSEG_mtpi_WS) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
crs(iSEG_mtpi_RG) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
iSEG_WS_ta<-readOGR(paste0(path_analysis_results_6a_iSEG05_WS_ta, "iSEG_WS_ta.shp"))
iSEG_RG_ta<-readOGR(paste0(path_analysis_results_6c_iSEG05_RG_ta, "iSEG_RG_ta.shp"))
crs(iSEG_WS_ta) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
crs(iSEG_RG_ta) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
iSEG_mtpi_WS_ta<-readOGR(paste0(path_analysis_results_6b_iSEG05_mtpi_WS_ta, "iSEG_mtpi_WS_ta.shp"))
iSEG_mtpi_RG_ta <-readOGR(paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta, "iSEG_mtpi_RG_ta.shp"))
crs(iSEG_mtpi_WS_ta) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
crs(iSEG_mtpi_RG_ta) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
################################################################################
####-----------------------------#COMPARE RESULTS#-------------------------#####
#The tests were done on one tile with two different data preparation and segmentation
#methods (5a-7d) and then the same was tested on on 5 tiles (6a-8d), to
#a) see how the results change with a bigger data set
#b) if new steps have to be implemented based on the amount of data
#c) if it was possible to use the same settings in the respective steps
#d) if it is worth it to preprocess the data to be able to emphasize the
#geomorphology of the terrain (and the mounds themselves included)
#when using mtpi as pre-processing, it was also possible to detect burial mounds_35
####--------------------#trainDTM: one 5x5 km2 tile#-------------------------####
#5a WS
#5b mtpi_WS
#5c RG
#5d mtpi_RG

#With the interactive mapview map it is possible to inspect the segmentation results
#in live modus:
mapview::mapview(mounds_5_35, col.regions = "blue") +
mapview::mapview(iSEG_WS, col.regions = "goldenrod") +
mapview::mapview(iSEG_mtpi_WS, col.regions= "coral4") +
mapview::mapview(iSEG_RG, col.regions="darkslategray4") +
mapview::mapview(iSEG_mtpi_RG, col.regions="burlywood4")

#It can be said, that with the mtpi pre-processing the resulting segments
#delineate the objects better - relatively to the not pre-processed DTM
#Judging from the 1 tile results, the iSEG_mtpi_WS workflow creates the most
#describing segments (except for burial_mounds_35 which is in a filed and is
#practically not traceable in the LiDAR data).
#Is it the same with the testarea (5 tiles)?
####-----------------------#trainarea:5 5x5 km2 tile#------------------------####
#6a WS_ta
#6b mtpi_WS_ta
#6c RG_ta
#6d mtpi_RG_ta
mapview::mapview(all_train_mounds, col.regions = "blue") +
mapview::mapview(iSEG_WS_ta, col.regions = "goldenrod") +
mapview::mapview(iSEG_mtpi_WS_ta, col.regions= "coral4") +
mapview::mapview(iSEG_RG_ta, col.regions="darkslategray4") +
mapview::mapview(iSEG_mtpi_RG_ta, col.regions="burlywood4")

#The first thing which can be noticed is that the bigger the train area the more
#"extra" segments there are. Also in a smaller area the iSEG_mtpi_WS is working very
#well, but on a larger scale it produces amorph segments which will result
#in a lot of false positives. Thus it suggests that scale definitely does matter.

#The runner ups at a larger scale are as well the pre-processed segmentation results.
#iSEG_mtpi_WS_ta #with a lot more false positive segments than iSEG_mtpi_RG_ta, but
#also more actual burial mounds area found.

mapview::mapview(all_train_mounds, col.regions = "blue") +
mapview::mapview(iSEG_mtpi_WS_ta, col.regions= "coral4") +
mapview::mapview(iSEG_mtpi_RG_ta, col.regions="burlywood1")

#The questions are: do we want exact segmentation results? Do we want to locate all
#burial mounds? Of course both together would be phenomenal, but in this case
#(non of the mounds are higher than 0.5 m) we should be happy with both segmentation
#results.

#One big truth is: the segmentation algorithm has to depict the burial mound segments
#better but for that we also need a better delineation of the mounds (the 2018
#LiDAR dataset and better data preparation method)

#All in all the iSEG_mtpi_WS_ta algorithm was chosen for the test areas because
#it captured the archaeology better.

################################################################################
#an integer vector is returned for the segmentation results, with NA values for
#locations where the  segmentation result is not matching with locations in the
#train polygons (e.g. points outside of the train polygons).

####----------------#Statistical evaluation of segmentation#----------------####
####---------------#INTERSECTION OVER UNION = JACCARD INDEX#----------------####

                              ####Solution 1####
#https://towardsdatascience.com/intersection-over-union-iou-calculation-for-evaluating-an-image-segmentation-model-8b22e2e84686
#percent overlap between the target mask and the prediction output
#IoU = Overlap/Union
#is segmentation correct:1; the lower the IoU the worse the segmentation

#intersection(A, B)
#union(A,B)
#IoU_score =  intersection/union

#intersection (A∩B) is comprised of the pixels found in both the segmentation
#and the mound segments, whereas the union (A∪B) is simply comprised of all
#pixels found in either the segmentation or mound segments.
#the IoU metric measures the number of pixels common between the mound segments and
#segmentation divided by the total number of pixels present across both segments.

intersection_iSEG_mtpi_WS_ta <- raster::intersect(all_train_mounds, iSEG_mtpi_WS_ta)
union_iSEG_mtpi_WS_ta <- raster::union(all_train_mounds, iSEG_mtpi_WS_ta)
mapview::mapview(union_iSEG_mtpi_WS_ta)
IoU_iSEG_mtpi_WS_ta<-union_iSEG_mtpi_WS_ta$A.1/intersection_iSEG_mtpi_WS_ta$A.1
#Warning message: In union_iSEG_mtpi_WS_ta$A.1/intersection_iSEG_mtpi_WS_ta$A.1 :
#longer object length is not a multiple of shorter object length

                             ####Solution 2####
####-------------------------#iSEG_mtpi_WS_ta#------------------------------####
#INTERSECTION = OVERLAP; all the elements present in the intersection of A AND B
intersection_iSEG_mtpi_WS_ta <- rgeos::gIntersection(all_train_mounds, iSEG_mtpi_WS_ta)

#UNION = AND; A + B
union_iSEG_mtpi_WS_ta <- rgeos::gUnion(all_train_mounds, iSEG_mtpi_WS_ta)

#SYMMETRIC DIFFERENCE: consist of all the elements present in either A or B but
#not in the intersection of A and B = disjunctive union
symdiff_iSEG_mtpi_WS_ta <- rgeos::gSymdifference(all_train_mounds, iSEG_mtpi_WS_ta)

#DIFFERENCE # gDifference: returns the regions of spgeom1 that are not within spgeom2
diff_iSEG_mtpi_WS_ta_1 <- rgeos::gDifference(iSEG_mtpi_WS_ta, all_train_mounds)
diff_iSEG_mtpi_WS_ta_2 <- rgeos::gDifference(all_train_mounds, iSEG_mtpi_WS_ta)

mapview::mapview(all_train_mounds, col.regions = "blue") +
mapview::mapview(iSEG_mtpi_WS_ta, col.regions = "green") +
mapview::mapview(union_iSEG_mtpi_WS_ta, col.regions = "yellow") +
mapview::mapview(symdiff_iSEG_mtpi_WS_ta, col.regions = "goldenrod") +
mapview::mapview(intersection_iSEG_mtpi_WS_ta, col.regions = "cadetblue") +
mapview::mapview(diff_iSEG_mtpi_WS_ta_1, col.regions = "red") +
mapview::mapview(diff_iSEG_mtpi_WS_ta_2, col.regions = "brown")

####--------------------------#iSEG_mtpi_RG_ta------------------------------####
#INTERSECTION = OVERLAP; all the elements present in the intersection of A AND B
intersection_iSEG_mtpi_RG_ta <- rgeos::gIntersection(all_train_mounds, iSEG_mtpi_RG_ta)

#UNION = AND; A + B
union_iSEG_mtpi_RG_ta <- rgeos::gUnion(all_train_mounds, iSEG_mtpi_RG_ta)

#SYMMETRIC DIFFERENCE: consist of all the elements present in either A or B but
#not in the intersection of A and B = disjunctive union
symdiff_iSEG_mtpi_RG_ta <- rgeos::gSymdifference(all_train_mounds, iSEG_mtpi_RG_ta)

#DIFFERENCE # gDifference: returns the regions of spgeom1 that are not within spgeom2
diff_iSEG_mtpi_RG_ta <- rgeos::gDifference(all_train_mounds, iSEG_mtpi_RG_ta)

mapview::mapview(all_train_mounds, col.regions = "blue") +
mapview::mapview(iSEG_mtpi_RG_ta, col.regions = "green") +
mapview::mapview(union_iSEG_mtpi_RG_ta, col.regions = "yellow") +
mapview::mapview(symdiff_iSEG_mtpi_RG_ta, col.regions = "slategray4") +
mapview::mapview(intersection_iSEG_mtpi_RG_ta, col.regions = "mistyrose4") +
mapview::mapview(diff_iSEG_mtpi_RG_ta, col.regions = "red")
