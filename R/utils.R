# Utilities used by movr package
# By Xiaming Chen <chenxm35@gmail.com>

# Rotate a matrix by 90 degree
#' Rotate a matrix by 90 degrees
#' 
#' Rotate a matrix by 90 degrees clockwise.
#' Rotate matrix 90 degrees clockwise
#' 
#' Rotate a matrix 90 degrees clockwise by transposing and reversing columns.
#' 
#' @param m A matrix to rotate
#' @return The rotated matrix
#' @export
#' @examples
#' m <- matrix(1:9, nrow=3)
#' rot90(m)
rot90 <- function(m) t(m)[,nrow(m):1]


#' Root Mean Squared Error (RMSE)
#' 
#' calculate the root mean squared error (RMSE) of two vectors.
#' 
#' @param x A given vector to calculate RMSE.
#' @param y The target vector
#' @export
#' @examples
#' RMSE(c(1,2,3,4), c(2,3,2,3))
RMSE <- function(x, y){
  if( !(class(x) == class(y)
        & class(x) %in% c("matrix", "numeric")) ) {
    stop("The input should be matrix or vector")
  }
  
  x = c(x); y = c(y)
  sqrt(mean((x-y)^2))
}


#' Geographic area checking
#' 
#' Check if the given lon-lat pair falls into specific area.
#' The area is a 4-length vector with lon-lat pairs of two points that
#' confine the area boundaries.
#' @param lon,lat The point to be checked.
#' @param area The area defined by two points c(lon1, lat1, lon2, lat2).
#' @export
#' @examples
#' in.area(120.1, 30.1, c(120.0,30.0,120.5,30.5))
in.area <- function(lon, lat, area){
  lon1 <- area[1]; lat1 <- area[2]
  lon2 <- area[3]; lat2 <- area[4]
  lons <- sort(c(lon1, lon2))
  lats <- sort(c(lat1, lat2))
  (lon >= lons[1] & lon <= lons[2] & lat >= lats[1] & lat <= lats[2])
}


#' Euclidean distance between two points
#' 
#' Calculate the Euclidean distance between two points in any dimension.
#' 
#' @param x1 First point as a numeric vector
#' @param x2 Second point as a numeric vector
#' @return The Euclidean distance between the two points
#' @export
#' @examples
#' euc.dist(c(0,0), c(3,4))
euc.dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))

#' Convert longitude/latitude to x/y coordinates
#' 
#' Convert geographic coordinates (longitude/latitude) to local x/y coordinates
#' using great circle distances from the minimum longitude and latitude points.
#' 
#' @param lon Vector of longitude coordinates
#' @param lat Vector of latitude coordinates
#' @return A data frame with x and y columns representing local coordinates
#' @export
#' @examples
#' lonlat2xy(c(120, 120.1, 120.2), c(30, 30.1, 30.2))
lonlat2xy <- function(lon, lat) {
  lon.min <- min(lon)
  lon.max <- max(lon)
  lat.min <- min(lat)
  lat.max <- max(lat)
  p0 <- c(lat.min, lon.min)
  res <- sapply(1:length(lon), function(i){
    x <- gcd(p0, c(lat.min, lon[i]))
    y <- gcd(p0, c(lat[i], lon.min))
    c(x, y)
  })
  res <- as.data.frame(t(res))
  colnames(res) <- c('x', 'y')
  res
}

# pseudo spatiotemporal data generator
.pseudo_movement <- function() {
  data.frame(x=rep(1:10, 5), y=rep_each(1:10, 5), t=1:50)
}


#' Melt time into parts
#' 
#' @param epoch the UNIX epoch timestamp in seconds
#' @param tz the time zone string
#' @return several fields (indexed by order) of given timestamp:
#'  year, month, day, hour, minute, second,
#'  day of week (dow),
#'  day of year (doy),
#'  week of month (wom),
#'  week of year (woy),
#'  quarter of year (qoy)
#' @export
melt_time <- function(epoch, tz='Asia/Shanghai') {
  pt <- as.POSIXct(epoch, origin="1970-01-01", tz=tz)
  year = format(pt, "%Y")
  month = format(pt, "%m")
  day = format(pt, "%d")
  hour = format(pt, "%H")
  minute = format(pt, "%m")
  second = format(pt, "%S")
  dow = format(pt, "%a")
  doy = format(pt, "%j")
  wom = ceiling(as.numeric(day) / 7)
  woy = format(pt, "%V")
  qoy = quarters(pt, abbreviate=TRUE)
  list(year=year, month=month, day=day, hour=hour, minute=minute, second=second,
       dow=dow, doy=doy, wom=wom, woy=woy, qoy=qoy)
}

#' Converting UNIX hour to Data object
#' 
#' Convert UNIX hour (calculated by dividing UNIX seconds with 3600)
#' to date at local time zone.
#' 
#' @param hour Hours from UNIX epoch
#' @param tz The time zone string
#' @export
hour2date <- function(hour, tz="Asia/Shanghai"){
  as.Date(as.POSIXct(hour*3600, origin="1970-01-01"), tz=tz)
}

#' Converting UNIX hour to Time-of-Day
#' 
#' Convert UNIX hour (calculated by dividing UNIX seconds with 3600)
#' to to Time-of-Day (TOD) at local time zone.
#' 
#' @param hour Hours from UNIX epoch
#' @param tz The time zone string
#' @export
hour2tod <- function(hour, tz = 'Asia/Shanghai'){
  pt <- as.POSIXct(hour*3600, origin="1970-01-01")
  format(pt, "%H")
}

#' Converting UNIX hour to Time-of-Week
#' 
#' Convert UNIX hour (calculated by dividing UNIX seconds with 3600)
#' to to Time-of-Week (TOW) at local time zone.
#' 
#' @param hour Hours from UNIX epoch
#' @param tz The time zone string
#' @export
hour2tow <- function(hour, tz='Asia/Shanghai'){
  pt <- as.POSIXct(hour*3600,origin="1970-01-01", tz=tz)
  weekdays(pt, abbreviate = TRUE)
}

#' R Colors
#' 
#' Plot matrix of R colors, in index order, 25 per row.
#' This is for quick reference when programming.
#' 
#' Copyright: Earl F. Glynn
#' @usage
#'   Rcolors(huesort=TRUE)
#' @param huesort Boolean value to control ordering by HUE.
#' @references http://research.stowers-institute.org/efg/R/Color/Chart/
#' @aliases Rcolours
#' @export
Rcolors <- function(huesort=TRUE) {
  
  # This example plots each row of rectangles one at a time.
  SetTextContrastColor <- function(color){
    ifelse( mean(col2rgb(color)) > 127, "black", "white")
  }
  
  # Define this array of text contrast colors that correponds to each
  # member of the colors() array.
  TextContrastColor <- unlist( lapply(colors(), SetTextContrastColor) )
  
  colCount <- 25 # number per row
  rowCount <- 27
  
  alpha.ordered <- function() {
    plot( c(1,colCount), c(0,rowCount), type="n", ylab="", xlab="",
          axes=FALSE, ylim=c(rowCount,0))
    title("R colors")
    
    for (j in 0:(rowCount-1)) {
      base <- j*colCount
      remaining <- length(colors()) - base
      RowSize <- ifelse(remaining < colCount, remaining, colCount)
      rect((1:RowSize)-0.5,j-0.5, (1:RowSize)+0.5,j+0.5,
           border="black",
           col=colors()[base + (1:RowSize)])
      text((1:RowSize), j, paste(base + (1:RowSize)), cex=0.7,
           col=TextContrastColor[base + (1:RowSize)])
    }
    
  }
  
  hue.ordered <- function() {
    # 1b. Plot matrix of R colors, in "hue" order, 25 per row.
    # This example plots each rectangle one at a time.
    RGBColors <- col2rgb(colors()[1:length(colors())])
    HSVColors <- rgb2hsv( RGBColors[1,], RGBColors[2,], RGBColors[3,], maxColorValue=255)
    HueOrder <- order( HSVColors[1,], HSVColors[2,], HSVColors[3,] )
    
    plot(0, type="n", ylab="", xlab="",
         axes=FALSE, ylim=c(rowCount,0), xlim=c(1,colCount))
    title("R colors -- Sorted by Hue, Saturation, Value")
    
    for (j in 0:(rowCount-1)){
      for (i in 1:colCount){
        k <- j*colCount + i
        if (k <= length(colors())){
          rect(i-0.5,j-0.5, i+0.5,j+0.5, border="black", col=colors()[ HueOrder[k] ])
          text(i,j, paste(HueOrder[k]), cex=0.7, col=TextContrastColor[ HueOrder[k] ])
        }
      }
    }
  }
  
  if (huesort) hue.ordered()
  else alpha.ordered()
}

#' Voronoi to polygon
#'
#' Convert Voronoi diagram generated by `deldir` package into SpatialPolygons
#' http://stackoverflow.com/questions/12156475/combine-voronoi-polygons-and-maps/12159863#12159863
#' 
#' @param x A spatial object or matrix of coordinates
#' @param poly A polygon defining the boundary
#' @return A SpatialPolygonsDataFrame object
#' @export
voronoi2polygons <- function(x, poly) {
  if (!requireNamespace("deldir", quietly = TRUE)) {
    stop("Package 'deldir' is required for this function.")
  }
  if (.hasSlot(x, 'coords')) {
    crds <- x@coords  
  } else crds <- x
  if (!requireNamespace("sp", quietly = TRUE)) {
    stop("Package 'sp' is required for this function.")
  }
  bb = sp::bbox(poly)
  rw = as.numeric(t(sp::bbox(poly)))
  z <- deldir::deldir(crds[,1], crds[,2],rw=rw)
  w <- deldir::tile.list(z)
  polys <- vector(mode='list', length=length(w))
  for (i in seq(along=polys)) {
    pcrds <- cbind(w[[i]]$x, w[[i]]$y)
    pcrds <- rbind(pcrds, pcrds[1,])
    polys[[i]] <- sp::Polygons(list(sp::Polygon(pcrds)), ID=as.character(i))
  }
  SP <- sp::SpatialPolygons(polys)
  
  sp::SpatialPolygonsDataFrame(
    SP, data.frame(x=crds[,1], y=crds[,2], 
                   row.names=sapply(methods::slot(SP, 'polygons'),
                                    function(x) methods::slot(x, 'ID'))))  
}

#' Adding minor ticks to R basic plots
#' 
#' Add minor ticks for log-log plots based on R basic
#' graphic engine.
#' 
#' @param ax Which axis to add minor ticks
#' @param n The number of minor ticks in each segment
#' @param lab If show minor ticks' labels
#' @param tick.ratio Ratio of minor ticks' marks
#' @param mn,mx The min and max value of minor ticks
#' @param ... Other parameters for axis() function
#' @export
#' @family graphic extensions
minor.ticks.axis <- function(ax, n, lab=TRUE, tick.ratio=0.5, mn, mx,...){
  lims <- par("usr")
  if(ax %in% c(1,3)) lims <- lims[1:2] else lims[3:4]
  
  if (!requireNamespace("squash", quietly = TRUE)) {
    stop("Package 'squash' is required for this function.")
  }
  major.ticks <- squash::prettyInt(lims)
  if(missing(mn)) mn <- min(major.ticks)
  if(missing(mx)) mx <- max(major.ticks)
  
  major.ticks <- major.ticks[major.ticks >= mn & major.ticks <= mx]
  labels <-sapply(major.ticks,function(i) as.expression(bquote(10^ .(i))))
  if(lab)
    axis(ax,at=major.ticks,labels=labels,...)
  else
    axis(ax,at=major.ticks,labels=FALSE,...)
  
  n <- n+2
  minors <- log10(pretty(10^major.ticks[1:2],n))-major.ticks[1]
  minors <- minors[-c(1,n)]
  
  minor.ticks = c(outer(minors,major.ticks,`+`))
  minor.ticks <- minor.ticks[minor.ticks > mn & minor.ticks < mx]
  axis(ax, labels=FALSE,
       at=minor.ticks,
       tcl=par("tcl")*tick.ratio)
}

#' Geographic midpoint calculation
#' 
#' Calculate the midpoint given a list of locations denoted by
#' latitude and longitude coordinates.
#' 
#' @param lat,lon The location points
#' @param w The weighted value for each point
#' @return The geographic midpoint in lat/lon
#' @export
#' @references \url{http://www.geomidpoint.com/calculation.html}
#' @examples
#' lat <- c(30.2, 30, 30.5)
#' lon <- c(120, 120.4, 120.5)
#' 
#' # equal weight
#' midpoint(lat, lon)
#' 
#' # custom weight
#' w <- c(1, 2, 1)
#' midpoint(lat, lon, w)
#'
#' @seealso \code{\link{radius.of.gyration}}
midpoint <- function(lat, lon, w=rep(1, length(lat))) {
  if (length(lat) != length(lon) || length(lat) != length(w)) {
    stop("The lat, lon and weight vectors should be the same length")
  }
  
  df <- data.frame(lat=deg2rad(lat), lon=deg2rad(lon), w=w)
  
  # convert geographic to cartesian points
  df$x <- cos(df$lat) * cos(df$lon)
  df$y <- cos(df$lat) * sin(df$lon)
  df$z <- sin(df$lat)
  total.weight <- sum(df$w)
  
  # calculate weighted midpoint
  m.x <- 1.0 * sum(df$x * df$w) / total.weight
  m.y <- 1.0 * sum(df$y * df$w) / total.weight
  m.z <- 1.0 * sum(df$z * df$w) / total.weight
  
  # convert cartesian to geographic point
  cart2geo(c(m.x, m.y, m.z))
}