# Utility funcitons used by movr package
# By Xiaming Chen <chenxm35@gmail.com>

# Rotate a matrix by 90 degree
#' @export
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
#' in_area(120.1, 30.1, c(120.0,30.0,120.5,30.5))
in_area <- function(lon, lat, area){
  lon1 <- area[1]; lat1 <- area[2]
  lon2 <- area[3]; lat2 <- area[4]
  lons <- sort(c(lon1, lon2))
  lats <- sort(c(lat1, lat2))
  (lon >= lons[1] & lon <= lons[2] & lat >= lats[1] & lat <= lats[2])
}


#' @export
euc_dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))


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
  qoy = quarters(pt, abbr=T)
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