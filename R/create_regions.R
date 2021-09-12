#the code was adapted from here:
#https://gis.stackexchange.com/questions/79114/joining-nearest-neighbor-small-polygons-using-r

create_regions <- function(data) {
  group <- rep(NA, length(data))
  group_val <- 0
  while(NA %in% group) {
    index <- min(which(is.na(group)))
    nb <- unlist(data[index])
    nb_value <- group[nb]
    is_na <- is.na(nb_value)
    if(sum(!is_na) != 0){
      prev_group <- nb_value[!is_na][1]
      group[index] <- prev_group
      group[nb[is_na]] <- prev_group
    } else {
      group_val <- group_val + 1
      group[index] <- group_val
      group[nb] <- group_val
    }
  }
  group
}
