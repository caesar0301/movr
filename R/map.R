#' Add a 3D map surface
#' 
#' This method add a 3D map surface to the RGL plot. The backend map service is
#' supported by OpenStreetMap package. All parameters except for h are
#' consistent with the 'openmap' function in OSM.
#' 
#' @usage map3d(upperLeft, lowerRight, h = 0, ...)
#' @param upperLeft the upper left lat and long
#' @param lowerRight the lower right lat and long
#' @param h the horizontal plane to locate the map surface
#' @param ... all other parameters of \code{\link[OpenStreetMap]{openmap}}
#' @export
#' @seealso \code{\link[OpenStreetMap]{openmap}}
#' @examples
#' data(movement)
#' u1 <- subset(movement, id==3)
#' u1$time <- (u1$time - min(u1$time)) / 3600

#' region.lat1 <- min(u1$lat) - 0.005
#' region.lat2 <- max(u1$lat) + 0.005
#' region.lon1 <- min(u1$lon) - 0.005
#' region.lon2 <- max(u1$lon) + 0.005
#' 
#' \dontrun{
#' rgl.clear()
#' rgl.clear("lights")
#' rgl.bg(color="lightgray")
#' rgl.viewpoint(theta=30, phi=45)
#' rgl.light(theta = 45, phi = 45, viewpoint.rel=TRUE)
#' map3d(c(region.lat2, region.lon1), c(region.lat1, region.lon2),
#'       min(u1$time), 10, "esri")
#' 
#' axes3d(edges = "bbox", labels = TRUE, tick = TRUE, nticks = 5, box=FALSE,
#'        expand = 1.03, col="black", lwd=0.8)
#' }
map3d <- function(upperLeft, lowerRight, h=0, ...) {
  map <- openmap(upperLeft, lowerRight, ...)
  map <- openproj(map)
  
  if(length(map$tiles)!=1){
    stop("multiple tiles not implemented")
  }
  
  tile = map$tiles[[1]]
  nx = tile$xres # number of tiles in longitude
  ny = tile$yres # number of tiles in latitude
  p1 = tile$bbox$p1 # upleft corner
  p2 = tile$bbox$p2 # downright corner
  
  xmin = min(p1[1], p2[1]) # longitude
  xmax = max(p1[1], p2[1])
  ymin = min(p1[2], p2[2]) # latitude
  ymax = max(p1[2], p2[2])
  
  xc = seq(xmin, xmax, len=ny)
  yc = seq(ymin, ymax, len=nx)
  
  col = matrix(tile$colorData, ny, nx)
  h <- matrix(h, nrow(col), ncol(col))
  
  rgl.surface(xc, rev(yc), h, col=col)
}