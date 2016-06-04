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
#' 
#' u1 <- subset(movement, id==3)
#' u1$time <- (u1$time - min(u1$time)) / 3600

#' lat1 <- min(u1$lat) - 0.005
#' lat2 <- max(u1$lat) + 0.005
#' lon1 <- min(u1$lon) - 0.005
#' lon2 <- max(u1$lon) + 0.005
#' \dontrun{
#' if(require(OpenStreetMap)){
#'  library(rgl)
#'  rgl.clear()
#'  rgl.clear("lights")
#'  rgl.bg(color="lightgray")
#'  rgl.viewpoint(theta=240, phi=45)
#'  rgl.light(theta = 45, phi = 45, viewpoint.rel=TRUE)
#'  map3d(c(lat1, lon1), c(lat2, lon2), h=min(u1$time))
#'  axes3d(edges = "bbox", labels = TRUE, tick = TRUE, nticks = 5, box=FALSE,
#'         expand = 1.03, col="black", lwd=0.8)
#'  invisible(readline(prompt="Press [enter] to continue"))
#'  rgl.close()
#' }}
map3d <- function(lowerLeft, upperRight, h=0, type='bing', ...) {
  library(OpenStreetMap)
  
  upperLeft <- c(upperRight[1], lowerLeft[2])
  lowerRight <- c(lowerLeft[1], upperRight[2])
  map <- openmap(upperLeft, lowerRight, type=type, ...)
  map <- openproj(map)
  
  if(length(map$tiles)!=1){
    stop("multiple tiles not implemented")
  }
  
  tile = map$tiles[[1]]
  xres = tile$xres # number of tiles in longitude
  yres = tile$yres # number of tiles in latitude
  p1 = tile$bbox$p1 # upleft corner
  p2 = tile$bbox$p2 # downright corner
  
  lonmin = min(p1[1], p2[1]) # longitude
  lonmax = max(p1[1], p2[1])
  latmin = min(p1[2], p2[2]) # latitude
  latmax = max(p1[2], p2[2])
  
  slon = seq(lonmin, lonmax, len=yres)
  slat = seq(latmin, latmax, len=xres)
  
  col = matrix(tile$colorData, xres, yres, byrow=T)
  h <- matrix(h, yres, xres)
  
  rgl.surface(slat, slon, t(h), col=col[xres:1,])
}

#' 3D voronoi canvas for RGL
#' @export
voronoi3d <- function(x, y, group_by=NULL, col=NULL, side='y', col.seg = "grey", lty=1, lwd=1) {
  stopifnot(length(x) == length(y), length(x) == length(group_by))
  stopifnot(tolower(side) %in% c('x', 'y', 'z'))
  
  if (is.null(group_by)) {
    group_by = rep(1, length(x))
    if (is.null(col)){
      col = colors()[sample(1:600, 1)]
    } else {
      stopifnot(length(col) == 1)
    }
  } else {
    stopifnot(length(x) == length(group_by))
    group_by = seq_distinct(group_by)
    glen = length(unique(group_by))
    if (is.null(col)) {
      col = colors()[sample(1:600, glen, replace = FALSE)]
    } else {
      stopifnot(length(col) == glen)
    }
  }
  
  bbox = par3d('bbox')
  br = range(bbox)
  if (br[1] - br[2] > 3e+30)
    stop("A valid rgl canvas is needed first when calling voronoi3d{movr}.")
  xr = bbox[1:2]
  yr = bbox[3:4]
  zr = bbox[5:6]
  side = tolower(side)
  coord = cbind(xr, yr, zr)[,which(side == c('x', 'y', 'z'))]
  
  plot.direchlet.tess <- function(points) {
    points.all = dplyr::distinct(points)
    dd = deldir(points.all[,1], points.all[,2])
    dirsgs = dd$dirsgs
    p1 = as.vector(t(dirsgs[,c(1,3)]))
    p2 = as.vector(t(dirsgs[,c(2,4)]))
    p3 = rep(coord[1], 2)
    if (side == 'x') {
      x = p3
      y = p1
      z = p2
    } else if (side == 'y') {
      x = p1
      y = p3
      z = p2
    } else {
      x = p1
      y = p2
      z = p3
    }
    rgl.lines(x=x, y=y, z=z, lwd=lwd, lty=lty, color=col.seg)
  }
  
  plot.points <- function(points, col) {
    points = dplyr::distinct(points)
    s1 = as.vector(points[,1])
    s2 = as.vector(points[,2])
    s3 = rep(coord[1], 2)
    if (side == 'x') {
      px = s3
      py = s1
      pz = s2
    } else if (side == 'y') {
      px = s1
      py = s3
      pz = s2
    } else {
      px = s1
      py = s2
      pz = s3
    }
    rgl.points(x=px, y=py, z=pz, color=col, alpha=0.5)
  }
  
  points <- data.frame(x=x, y=y, group=group_by)
  plot.direchlet.tess(points)
  for ( g in unique(points$group) ) {
    plot.points(subset(points, group==g), col[g])
  }
}