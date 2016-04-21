#'
#' http://stackoverflow.com/questions/12156475/combine-voronoi-polygons-and-maps/12159863#12159863
#' @export
voronoi2polygons <- function(x, poly) {
  require(deldir)
  if (.hasSlot(x, 'coords')) {
    crds <- x@coords  
  } else crds <- x
  bb = bbox(poly)
  rw = as.numeric(t(bbox(poly)))
  z <- deldir(crds[,1], crds[,2],rw=rw)
  w <- tile.list(z)
  polys <- vector(mode='list', length=length(w))
  require(sp)
  for (i in seq(along=polys)) {
    pcrds <- cbind(w[[i]]$x, w[[i]]$y)
    pcrds <- rbind(pcrds, pcrds[1,])
    polys[[i]] <- Polygons(list(Polygon(pcrds)), ID=as.character(i))
  }
  SP <- SpatialPolygons(polys)
  
  SpatialPolygonsDataFrame(
    SP, data.frame(x=crds[,1], y=crds[,2], 
                   row.names=sapply(slot(SP, 'polygons'),
                                    function(x) slot(x, 'ID'))))  
}