polygonize_segments_SAGA <- function(segments, tmp, class_all, class_id,
                                     split, all_vertices) {
  cat(" ", sep = "\n")
  cat("----function polygonize_segments_SAGA starts----")
  RSAGA::rsaga.geoprocessor(lib = "shapes_grid", module = 6,
                            param = list(GRID=paste(tmp,"/segments.sgrd", sep = ""),
                                         POLYGONS=paste(tmp,"/segments.shp", sep = ""),
                                         CLASS_ALL=class_all,
                                         CLASS_ID=class_id,
                                         SPLIT=split,
                                         ALLVERTICES=all_vertices),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  cat(" ", sep = "\n")
  cat("----polygonize_segments_SAGA finished----")
  cat(" ", sep = "\n")
}
