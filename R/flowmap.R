#' Compress movement history
#' 
#' Remove duplicate location records in user's movement history.
#' Continuous records at the same location is merged into a single session
#' (with interval less than `gap`) recording the starting and ending times.
#' 
#' @param x,y,t see params of \code{\link{stcoords}}
#' @param gap the time tolerance (sec) to conbime two continuous observations
#' @export
#' @seealso \code{\link{seq_collapsed}}
#' @examples
#' data(movement)
#' 
#' user_move <- subset(movement, id==1)
#' compress_mov(user_move[,c("loc", "time")])
#' 
#' ## With dplyr
#' library(dplyr)
#' movement %>% filter(id<10) %>% group_by(id) %>% do(compress_mov(x=.$loc, t=.$time))
#' 
compress_mov <- function(x, y=NULL, t=NULL, gap=0.5 * 3600) {
  st = stcoords_1d(x, y, t)
  sx = as.integer(st$sx)
  tt = as.numeric(st$t)
  
  compressed <- as.data.frame(.Call("_compress_mov", sx, tt, gap))
  colnames(compressed) <- c("loc", "stime", "etime")
  
  compressed
}

#' Calculate flow stat between locations
#' 
#' @param loc A 1D vector to record locations of movement history
#' @param stime The starting timestamp (SECONDS) vector of movement history
#' @param etime The ending timestamp (SECONDS) vector of movement history
#' @param gap The temporal idle interval
#' @export
flowmap_stat <- function(loc, stime, etime, gap=8*3600) {
  stopifnot(length(loc) == length(stime) && length(loc) == length(etime))
  stopifnot(is.numeric(stime))
  stopifnot(is.numeric(etime))
  
  loc = as.character(loc)
  fstat = .Call("_flow_stat", loc, stime, etime, gap)
  df = as.data.frame(fstat)
  colnames(df) = c("edge", "freq")
  df
}

#' Generate flowmap from movement data
#' 
#' Use historical movement data to generate flowmap, which records mobility
#' statistics between two locations 'from' and 'to'.
#' 
#' @param uid a vector to record user identities
#' @param loc a 1D vector to record locations of movement history
#' @param time the timestamp (SECONDS) vector of movement history
#' @param gap the maximum dwelling time to consider a valid move between locations.
#' @return a data frame with four columns: from, to, total, unique (users)
#' @export
#' @seealso \code{\link{flowmap2}}
#' @examples
#' data(movement)
#' \dontrun{
#' with(movement, flowmap(id, loc, time))
#' }
flowmap <- function(uid, loc, time, gap=8*3600) {
  # remove duplicated info in user movement hisotry
  compressed <- data.frame(uid=uid, loc=loc, time=time) %>%
    dplyr::group_by(uid) %>%
    dplyr::do(compress_mov(x=.$loc, t=.$time))
  
  with(compressed, flowmap2(uid, loc, stime, etime, gap))
}

#' Generate flowmap from movement data
#' 
#' Use historical movement data to generate flowmap, which records mobility
#' statistics between two locations 'from' and 'to'.
#' 
#' Different from \code{flowmap}, compressed movement history is used to
#' generate flow statistics.
#'
#' @param uid a vector to record user identities
#' @param loc a 1D vector to record locations of movement history
#' @param stime,etime compressed session time at each location
#' @param gap the maximum dwelling time to consider a valid move between locations
#' @return a data frame with four columns: from, to, total, unique (users)
#' @export
#' @seealso \code{\link{flowmap}}
flowmap2 <- function(uid, loc, stime, etime, gap=8*3600) {
  compressed <- data.frame(uid=uid, loc=loc, stime=stime, etime=etime)
  
  fmap <- compressed %>%
    group_by(uid) %>%
    dplyr::do( flowmap_stat(.$loc, .$stime, .$etime, gap)) %>%
    group_by(edge) %>%
    dplyr::summarise(
      total = sum(freq),
      unique = length(unique(uid))) %>%
    separate(edge, c("from", "to"), sep="->")
  
  fmap
}

#' Visualize flowmap.
#' 
#' Visualize the mobility statistics (flowmap) from data. Each row in the data
#' will generate a line on the map.
#' 
#' @param from_lat, from_lon The latitude/longitude coordinates of departing point for mobile transitions.
#' @param to_lat, to_lon The latitude/longitude coordinates of arriving point for mobile transitions.
#' @param bg The background color for output figure.
#' @param gc.breaks The number of intermediate points (excluding two ends) to draw a great circle path.
#' @param col.pal A color vector used by \code{colorRampPalette}; must be a valid argument to \code{col2rgb}.
#'        Refer to \url{colorbrewer2.org} to derive more palettes.
#' @param col.pal.bias The bias coefficient used by \code{colorRampPalette}. Higher values give more widely
#'        spaced colors at the high end.
#' @param col.pal.grad The number of color grades to diffeciate distance.
#'
#' @seealso \code{\link{flowmap}}, \code{\link{flowmap2}}, \code{\link{flowmap_stat}}
#' @export
draw_flowmap <- function(from_lat, from_lon, to_lat, to_lon, bg="black", gc.breaks=5,
                         col.pal=c("white", "blue", "black"), col.pal.bias=0.3, col.pal.grad=200) {  
  df <- data.frame(from_lat=from_lat, from_lon=from_lon, to_lat=to_lat, to_lon=to_lon)
  
  # add great circle distances
  dist = apply(df, 1, function(x)
    distGeo(x[c('from_lon', 'from_lat')], x[c('to_lon', 'to_lat')]))
  maxdist = max(dist)
  mindist = min(dist)
  df <- df %>% mutate(dist_ord = movr::vbin(log(dist + 0.001), col.pal.grad)) %>%
    mutate(dist_perc=(dist-mindist)/(maxdist - mindist))
  
  x_axis = seq(min(c(df$from_lon, df$to_lon)), max(c(df$from_lon, df$to_lon)), length.out = 100)
  y_axis = seq(min(c(df$from_lat, df$to_lat)), max(c(df$from_lat, df$to_lat)), length.out = 100)
  
  opar <- par()
  par(bg="black")
  plot(x_axis, y_axis, type="n", axes=F, xlab="", ylab="")
  
  pal.1 <- colorRampPalette(col.pal, bias=col.pal.bias)(col.pal.grad)
  
  apply(df, 1, function(x) {
    p1 = as.numeric(c(x['from_lon'], x['from_lat']))
    p2 = as.numeric(c(x['to_lon'], x['to_lat']))
    
    # use geosphere to generate intermediate points of great circles
    cps = gcIntermediate(p1, p2, n=gc.breaks, addStartEnd=T)
    
    # col = scales::alpha('blue', 1-x['dist_perc'])
    col = pal.1[x['dist_ord']] # longest dist takes black color
    
    lines(cps, col=col)
  })
  
  par(opar)
}