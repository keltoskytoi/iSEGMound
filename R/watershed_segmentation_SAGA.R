watershed_SAGA <- function(dtm, output, tmp, output_choice, down, join,
                           threshold, edge, borders, crs) {
  cat(" ", sep = "\n")
  cat("----function watershed_SAGA starts----")
  raster::writeRaster(dtm, filename=paste0(file.path(tmp),"/dtm.sdat"), overwrite = TRUE, NAflag = 0)
  RSAGA::rsaga.geoprocessor(lib = "imagery_segmentation", module = 0,
                            param = list(GRID=paste(tmp,"/dtm.sgrd", sep = ""),
                                         SEGMENTS=paste(tmp,"/segments.sgrd", sep = ""),
                                         SEEDS=paste(tmp,"/seeds.shp", sep = ""),
                                         BORDERS=paste0(path_tmp,"/borders.sgrd", sep=""),
                                         OUTPUT=output_choice,
                                         DOWN=down,
                                         JOIN=join,
                                         THRESHOLD=threshold,
                                         EDGE=edge,
                                         BBORDERS=borders),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  cat(" ", sep = "\n")
  cat("----projecting segments----")
  prjctn <- crs
  segments <- raster::raster(paste0(tmp, "/segments.sdat"))
  proj4string(segments) <- prjctn
  cat(" ", sep = "\n")
  cat("----exporting segments----")
  raster::writeRaster(segments, filename=paste0(file.path(output), "/segments.tif"), overwrite = TRUE, NAflag = 0)
  cat(" ", sep = "\n")
  cat("----watershed_SAGA finished----")
  cat(" ", sep = "\n")
}
