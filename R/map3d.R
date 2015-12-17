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
#'       h=min(u1$time), zoom=10, type="esri")
#' 
#' axes3d(edges = "bbox", labels = TRUE, tick = TRUE, nticks = 5, box=FALSE,
#'        expand = 1.03, col="black", lwd=0.8)
#' }
map3d <- function(upperLeft, lowerRight, h=0, ...) {
  library(OpenStreetMap)
  
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

#' Visualize 3D mobility data with RGL.
#' 
#' @param x,y Numeric vectors of spatial coordinates
#' @param t The temporal vector for each (x,y) point.
#' @param group_by A group indicator when multiple users are visualized.
#' @param col A vector of color strings. It must have the same length as unique(group_by).
#' @param xlab,ylab,tlab The labels for each axis.
#' @param ... Other parameters for \code{\link[rgl]{plot3d}} or \code{\link[rgl]{axes3d}}
#' @export
#' @examples
#' data(movement)
#' 
#' users <- subset(movement, id %in% c(23, 20)) %>%
#'  mutate(time = time/86400 - min(time/86400)) %>%
#'  dplyr::filter(time <= 30)
#'  
#' \dontrun{
#' draw_mobility3d(users$lon, users$lat, users$time,
#'  group_by=users$id, col=c('royalblue', 'orangered'))
#' }
draw_mobility3d <- function(x, y, t, group_by=NULL, col=NULL, xlab="", ylab="", tlab="", ...) {
  library(rgl)
  library(deldir)
  
  stopifnot(length(x) == length(y) && length(x) == length(t))
  
  #t <- strftime(as.POSIXct(t, origin="1970-01-01"), format="%m%d-%H:%M")
  
  par3d(windowRect=c(20,40,800,800), cex='0.8')
  rgl.clear()
  rgl.clear("lights")
  rgl.bg(color="white")
  rgl.viewpoint(theta = 40, phi = 10)
  rgl.light(theta = -15, phi = 30, viewpoint.rel=TRUE)
  
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
  
  plot3d(x, t, y, type='n', xlab=xlab, ylab=tlab, zlab=ylab, axes=FALSE, ...)
  
  for (g in unique(group_by)) {
    x0 = x[group_by==g]
    t0 = t[group_by==g]
    y0 = y[group_by==g]
    plot3d(x0, t0, y0, type='p', col=col[g], add=TRUE, ...)
    lines3d(x0, t0, y0, color=col[g], ...)
  }
  
  voronoi3d(x, y, group_by, col)
  
  # axes3d(edges=c("x--", "y--", "z"))
  # axes3d(lwd=0.7, xlen=8, ylen=10, zlen=8, col='black', marklen=40)
  
  axes3d(edges=c('z+-', 'x-+', 'y-+'),
         col='black', nticks=7, expand=1,
         labels = FALSE, tick = FALSE, ...)
}


#' @export
mobility3d.close <- function() {
  rgl.close()
}


# plot 3D voronoi canvas
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
