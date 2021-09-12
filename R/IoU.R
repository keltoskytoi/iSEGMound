#based on: https://rdrr.io/github/weecology/NeonTreeEvaluation_package/man/IoU.html

IoU <- function(x, y) {
  #calculate the area of intersection
  intersection <- st_intersection(st_geometry(x), st_geometry(y))
  if (length(intersection)==0) {
    return(0)
  }
  area_intersection <-  st_area(intersection)
  #calculate the area of union
  area_union <- (st_area(x) + st_area(y)) - area_intersection
  return(area_intersection/area_union)
}
