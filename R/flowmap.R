#' Detect staying sessions of user
#' 
#' This funciton removes duplicate location records in user's mobility trajectory.
#' Successive records at the same location are merged into a single session
#' (with interval less than `gap`) recording the starting and ending times.
#' 
#' @param x,y,t see params of \code{\link{stcoords}}
#' @param gap the time tolerance (sec) to conbime two continuous observations
#' @param unite.sep a separator to combine x and y coordinators into one column,
#'  see also \code{\link{stcoords}}
#' @export
#' @seealso \code{\link{flowmap}}, \code{\link{flowmap2}}, \code{\link{flow.stat}}
#' @examples
#' data(movement)
#' u1 <- movement %>% dplyr::filter(id==2)
#' 
#' ## 1-colume location indicators
#' head(gen.sessions(u1$loc, t=u1$time))
#' 
#' ## 2-columes location coordinates
#' head(gen.sessions(u1$lon, u1$lat, u1$time))
gen.sessions <- function(x, y=NULL, t=NULL, gap=0.5*3600, unite.sep='_') {
  stc = stcoords(x, y, t)
  is_1d = stc$is_1d
  
  if (is_1d) {
    ssdd = seq_distinct(as.character(stc$x))
  } else {
    # Merge x and y coords into 1 colume
    stc = stcoords(x, y, t, unite.xy=TRUE, unite.sep=unite.sep)
    ssdd = seq_distinct(stc$x)
  }
  
  sx = as.vector(ssdd)
  tt = as.numeric(stc$t)
  sessions <- as.data.frame(.Call("_compress_mov", sx, tt, gap))
  colnames(sessions) <- c("id", "stime", "etime")
  
  xy2id <- data.frame(xy=names(ssdd), id=as.vector(ssdd))
  xy2id <- xy2id[!duplicated(xy2id), ]
  if (!is_1d) {
    xy2id <- xy2id %>% separate(xy, into=c("x", "y"), sep=unite.sep)
  }
  
  sessions <- sessions %>% left_join(xy2id, by=c("id"="id")) %>% subset(select=-id)
  if (is_1d) {
    colnames(sessions) <-c('stime', 'etime', 'loc')
  }
  sessions
}

#' Calculate flow stat between locations
#' 
#' @param loc A 1D vector to record locations of movement history
#' @param stime The starting timestamp (SECONDS) vector of movement history
#' @param etime The ending timestamp (SECONDS) vector of movement history
#' @param gap The temporal idle interval
#' @seealso \code{\link{gen.sessions}}, \code{\link{flowmap}}, \code{\link{flowmap2}},
#'    \code{\link{plot.flowmap}}
#' @export
#' @examples
#' data(movement)
#' 
#' user_move <- subset(movement, id==1)
#' sessions <- gen.sessions(user_move[,c("loc", "time")])
#' 
#' res <- with(sessions, flow.stat(loc, stime, etime))
#' head(res)
flow.stat <- function(loc, stime, etime, gap=86400) {
  stopifnot(length(loc) > 0
            && length(loc) == length(stime)
            && length(loc) == length(etime))
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
#' @seealso \code{\link{gen.sessions}}, \code{\link{flowmap2}}, \code{\link{flow.stat}},
#'    \code{\link{plot.flowmap}}
#' @export
#' @examples
#' data(movement)
#' 
#' res <- with(movement, flowmap(id, loc, time))
#' head(res)
flowmap <- function(uid, loc, time, gap=8*3600) {
  # remove duplicated info in user movement hisotry
  compressed <- data.frame(uid=uid, loc=loc, time=time) %>%
    dplyr::group_by(uid) %>%
    dplyr::do(gen.sessions(x=.$loc, t=.$time))
  
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
#' @seealso \code{\link{gen.sessions}}, \code{\link{flowmap}}, \code{\link{flow.stat}},
#'    \code{\link{plot.flowmap}}
#' @export
flowmap2 <- function(uid, loc, stime, etime, gap=86400) {
  compressed <- data.frame(uid=uid, loc=loc, stime=stime, etime=etime)
  
  fmap <- compressed %>%
    group_by(uid) %>%
    dplyr::do(flow.stat(.$loc, .$stime, .$etime, gap)) %>%
    group_by(edge) %>%
    dplyr::summarise(total = sum(freq)) %>%
    separate(edge, c("from", "to"), sep="->")
  
  as.data.frame(fmap)
}

#' Visualize flowmap.
#' 
#' Visualize the mobility statistics (flowmap) from data. Each row in the data
#' will generate a line on the map.
#' 
#' @param from_lat The latitude coordinates of departing point for mobile transitions.
#' @param from_lon The longitude coordinates of departing point for mobile transitions.
#' @param to_lat The latitude coordinates of arriving point for mobile transitions.
#' @param to_lon The longitude coordinates of arriving point for mobile transitions.
#' @param dist.log Whether using log-scale distance for line color.
#' @param weight The user-defined weight for line color. Larger weight corresponds to lefter color of col.pal.
#' @param weight.log Whether using log-scale weight for line color.
#' @param gc.breaks The number of intermediate points (excluding two ends) to draw a great circle path.
#' @param col.pal A color vector used by \code{colorRampPalette}; must be a valid argument to \code{col2rgb}.
#'        Refer to \url{colorbrewer2.org} to derive more palettes.
#' @param col.pal.bias The bias coefficient used by \code{colorRampPalette}. Higher values give more widely
#'        spaced colors at the high end.
#' @param col.pal.grad The number of color grades to diffeciate distance.
#' @param new.device Whether creating a new device for current plot. Set this parameter as FALSE when
#'  trying to plot multiple flowmaps in one figure.
#' @param bg The background color for current plot. It is working when new.device is TRUE.
#' @param ... Extra parameters for basic plot() function.
#'
#' @seealso \code{\link{gen.sessions}}, \code{\link{flowmap}}, \code{\link{flowmap2}},
#'    \code{\link{flow.stat}}
#' @export
plot.flowmap <- function(from_lat, from_lon, to_lat, to_lon, dist.log=TRUE, weight=NULL, weight.log=TRUE,
                         gc.breaks=5, col.pal=c("white", "blue", "black"), col.pal.bias=0.3,
                         col.pal.grad=200, new.device=TRUE, bg="black", ...) {  
  df <- data.frame(from_lat=from_lat, from_lon=from_lon, to_lat=to_lat, to_lon=to_lon)
  
  # add great circle distances
  dist = apply(df, 1, function(x)
    distGeo(x[c('from_lon', 'from_lat')], x[c('to_lon', 'to_lat')]))
  dist[is.na(dist)] <- 0
  
  if (is.null(weight)) {
    # longest dist takes black color
    col_ord = vbin(ifelse(rep(dist.log, length(dist)), log(dist+0.001), dist), col.pal.grad)
  } else {
    # smallest weight takes black color
    wgh = vbin(ifelse(rep(weight.log, length(dist)), log(weight), weight), col.pal.grad)
    col_ord = max(wgh) - wgh + 1
  }  
  
  df <- df %>% mutate(col_ord = col_ord)
  
  x_axis = seq(min(c(df$from_lon, df$to_lon)), max(c(df$from_lon, df$to_lon)), length.out = 100)
  y_axis = seq(min(c(df$from_lat, df$to_lat)), max(c(df$from_lat, df$to_lat)), length.out = 100)
  
  if (new.device) {
    opar <- par()
    par(bg=bg)
  }
  
  plot(x_axis, y_axis, type="n", axes=F, xlab="", ylab="", ...)
  
  # create color palette
  pal.1 <- colorRampPalette(col.pal, bias=col.pal.bias)(col.pal.grad)
  
  apply(df, 1, function(x) {
    p1 = as.numeric(c(x['from_lon'], x['from_lat']))
    p2 = as.numeric(c(x['to_lon'], x['to_lat']))
    
    if (sum(is.na(p1)) == 0 && sum(is.na(p2)) == 0) {
      # use geosphere to generate intermediate points of great circles
      cps = gcIntermediate(p1, p2, n=gc.breaks, addStartEnd=T)
      
      col = pal.1[x['col_ord']]
      
      lines(cps, col=col)
    }
  })
  
  if (new.device)
    par(opar)
}
