region_growing_SAGA <- function(seeds, dtm, tmp, output, normalize, neighbour,
                                method, sig_1, sig_2, threshold, leafsize, crs) {
  cat(" ", sep = "\n")
  cat("----function region_growing_SAGA starts----")
  RSAGA::rsaga.geoprocessor(lib = "imagery_segmentation", module = 3,
                            param = list(SEEDS=paste(tmp,"/seedpoints.sgrd", sep = ""),
                                         FEATURES=paste(tmp,"/dtm.sgrd", sep = ""),
                                         SEGMENTS=paste(tmp,"/segments.sgrd", sep = ""),
                                         SIMILARITY=paste0(path_tmp,"/similarity.sgrd", sep=""),
                                         NORMALIZE=normalize,
                                         NEIGHBOUR=neighbour,
                                         METHOD=method,
                                         SIG_1=sig_1,
                                         SIG_2=sig_2,
                                         THRESHOLD=threshold,
                                         LEAFSIZE=leafsize),
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
  cat("----region_growing_SAGA finished----")
  cat(" ", sep = "\n")
}



