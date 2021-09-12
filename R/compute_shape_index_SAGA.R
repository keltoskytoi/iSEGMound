compute_shape_index_SAGA <- function(segments, tmp, index, gyros, feret, feret_dirs) {
  cat(" ", sep = "\n")
  cat("----function compute_shape_index_SAGA starts----")
  RSAGA::rsaga.geoprocessor(lib = "shapes_polygons", module = 7,
                            param = list(SHAPES=paste(tmp,"/segments.shp", sep = ""),
                                         INDEX=paste(tmp,"/segments.shp", sep = ""),
                                         GYROS=gyros,
                                         FERET=feret,
                                         FERET_DIRS=feret_dirs),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  cat(" ", sep = "\n")
  cat("----compute_shape_index_SAGA finished----")
  cat(" ", sep = "\n")
}


