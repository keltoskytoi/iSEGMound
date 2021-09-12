################################################################################
####-------------#1.READ MOUNDS DOBIAT 1994 IN THE TRAIN AREA#--------------####
all_train_mounds<-st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "all_train_mounds.shp"))

mounds_5_35 <-st_read(paste0(path_analysis_data_burial_mounds_Dobiat_1994, "mounds_5_35.shp"))
####--------------------------#1.READ MOUND RESULTS#------------------------####
iSEG_WS <-st_read(paste0(path_analysis_results_5a_iSEG05_WS, "iSEG_WS.shp"))
iSEG_RG <-st_read(paste0(path_analysis_results_5c_iSEG05_RG, "iSEG_RG.shp"))
crs(iSEG_WS) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
crs(iSEG_RG) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
iSEG_mtpi_WS <-st_read(paste0(path_analysis_results_5b_iSEG05_mtpi_WS, "iSEG_mtpi_WS.shp"))
iSEG_mtpi_RG <-readOGR(paste0(path_analysis_results_5d_iSEG05_mtpi_RG, "iSEG_mtpi_RG.shp"))
crs(iSEG_mtpi_WS) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
crs(iSEG_mtpi_RG) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
iSEG_WS_ta<-readOGR(paste0(path_analysis_results_6a_iSEG05_WS_ta, "iSEG_WS_ta.shp"))
iSEG_RG_ta<-readOGR(paste0(path_analysis_results_6c_iSEG05_RG_ta, "iSEG_RG_ta.shp"))
crs(iSEG_WS_ta) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
crs(iSEG_RG_ta) #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs

iSEG_mtpi_WS_ta<-st_read(paste0(path_analysis_results_6b_iSEG05_mtpi_WS_ta, "iSEG_mtpi_WS_ta.shp"))
iSEG_mtpi_RG_ta <-st_read(paste0(path_analysis_results_6d_iSEG05_mtpi_RG_ta, "iSEG_mtpi_RG_ta.shp"))
st_crs(iSEG_mtpi_RG_ta) <-  st_crs(iSEG_mtpi_WS_ta)
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
####----------------#Statistical evaluation of segmentation#----------------####
####---------------#INTERSECTION OVER UNION = JACCARD INDEX#----------------####

#https://towardsdatascience.com/intersection-over-union-iou-calculation-for-evaluating-an-image-segmentation-model-8b22e2e84686
#percent overlap between the target mask and the prediction output
#IoU = Overlap/Union
#is segmentation correct: 1; the lower the IoU the worse the segmentation

#area of intersection/overlap(A∩B)
#area of union(A∪B)
#IoU_score =  intersection/union

#intersection (A∩B) is comprised of the pixels found in both the segmentation
#and the mound segments, whereas the union (A∪B) is simply comprised of all
#pixels found in the segmentation and mound segments.
#the IoU metric measures the number of pixels common between the mound segments and
#segmentation divided by the total number of pixels present across both segments.

#How to calculate it:
#https://www.pyimagesearch.com/2016/11/07/intersection-over-union-iou-for-object-detection/#:~:text=The%20Intersection%20over%20Union%20can,area%20would%20be%20doubly%20counted).

#compute the intersection over union by taking the intersection area
#and dividing it by the sum of segmentation + all_mound areas - the interesection area

####-------------------------#iSEG_mtpi_WS_ta#------------------------------####

#check the IDs of the iSEG_mtpi_WS_ta data frame
iSEG_mtpi_WS_ta$ID #ID's are not continuous
#change the ID's to continuous
#iSEG_mtpi_WS_ta$ID <- seq(nrow(iSEG_mtpi_WS_ta))

z#plot area  in question
mapview::mapview(all_train_mounds, col.regions = "blue") +
mapview::mapview(iSEG_mtpi_WS_ta, col.regions= "coral4")

#test function from the NeonTreeEvaluation_package
IoU_all_mtpiWSta <- IoU(all_train_mounds, iSEG_mtpi_WS_ta)

####------------------------------------------------------------------------####
#trace back of the function  to understand what is happening
#calculate intersection
intersection_all_mpti_WS_ta <- st_intersection(st_geometry(all_train_mounds), st_geometry(iSEG_mtpi_WS_ta))
#calculate area of intersection
area_intersection_all_mpti_WS_ta <-  st_area(intersection_all_mpti_WS_ta)
#calculate area of union
area_union_all_mpti_WS_ta <- st_area(all_train_mounds) + (st_area(iSEG_mtpi_WS_ta)) - area_intersection_all_mpti_WS_ta
#divide area of intersection by area of union
IoU_test <- (area_intersection_all_mpti_WS_ta/area_union_all_mpti_WS_ta)
IoU_all_mpti_WS_ta <- IoU(all_train_mounds, iSEG_mtpi_WS_ta)
####------------------------------------------------------------------------####

class(IoU_all_mtpiWSta) #units

#transform the results to a df to be able to work with it
orig_IDs <- tibble::as_data_frame(iSEG_mtpi_WS_ta$ID)
names(orig_IDs) <- "segment_ID"
class(orig_IDs)

IoU_all_mtpiWSta <- tibble::as_data_frame(IoU_all_mtpiWSta)
names(IoU_all_mtpiWSta) <- "IoU_value"

IoU_all_mtpiWSta_df <- dplyr::bind_cols(IoU_all_mtpiWSta, orig_IDs)

#extract the  values connected to the burial mound segments

#mound group 5
#10408
#9659
#9040
#8589
#8532
#9305
#10418
#11777
#6701

#mound group 7
#20459
#21710
#23107
#24408
#24081
#25726
#26119
#26203

#mound group 14
#65455
#58358
#81480
#84209
#84593
#87095
#83485
#90014
#90944
#88235
#91750
#93758
#95098
#96872
#103662
#105096
#106077
#89929




#mound 35
#13881




#we get values higher than 1; the negative values  are OK, because we have more
#segmentation results than mound segments








 ####--------------------------#iSEG_mtpi_RG_ta------------------------------####
