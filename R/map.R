#' Add a 3D map surface
#' 
#' This method add a 3D map surface to the RGL plot. The backend map service is
#' supported by OpenStreetMap package. All parameters except for h are
#' consistent with the 'openmap' function in OSM.
#' 
#' @usage map3d(upperLeft, lowerRight, h = 0, zoom = NULL,
#' type = c("osm", "osm-bw", "maptoolkit-topo", "waze", "mapquest", "mapquest-aerial", "bing", "stamen-toner", "stamen-terrain", "stamen-watercolor", "osm-german", "osm-wanderreitkarte", "mapbox", "esri", "esri-topo", "nps", "apple-iphoto", "skobbler", "cloudmade-<id>", "hillshade", "opencyclemap", "osm-transport", "osm-public-transport", "osm-bbike", "osm-bbike-german"),
#' minNumTiles = 9L, mergeTiles = TRUE)
#' @param upperLeft the upper left lat and long
#' @param lowerRight the lower right lat and long
#' @param h the horizontal plane to locate the map surface
#' @param zoom the zoom level. If null, it is determined automatically
#' @param type the tile server from which to get the map
#' @param minNumTiles If zoom is null, zoom will be chosen such that the number
#'     of map tiles is greater than or equal to this number.
#' @param mergeTiles should map tiles be merged into one tile
#' @export
#' @examples
#' data(movement)
#' u1 <- subset(movement, id==3)
#' u1$time <- (u1$time - min(u1$time)) / 3600

#' region.lat1 <- min(u1$lat) - 0.005
#' region.lat2 <- max(u1$lat) + 0.005
#' region.lon1 <- min(u1$lon) - 0.005
#' region.lon2 <- max(u1$lon) + 0.005
#' 
#' rgl.clear()
#' map3d(c(region.lat2, region.lon1), c(region.lat1, region.lon2),
#'       min(u1$time), 12, "esri")
#' 
#' axes3d(edges = "bbox", labels = TRUE, tick = TRUE, nticks = 5, box=FALSE,
#'        expand = 1.03, col="black", lwd=0.8)
map3d <- function(upperLeft, lowerRight, h=0, zoom = NULL, type="osm",
                  minNumTiles = 9L, mergeTiles = TRUE) {
  map <- openmap(upperLeft, lowerRight, zoom, type, minNumTiles, mergeTiles)
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