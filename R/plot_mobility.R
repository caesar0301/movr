#' Visualize trajectories using RGL 3D.
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
#' \dontrun{
#' plot_traj3d(users$lon, users$lat, users$time,
#'  group_by=users$id, col=c('royalblue', 'orangered'))
#' 
#' invisible(readline(prompt="Press [enter] to continue"))
#' traj3d.close()
#' }
plot_traj3d <- function(x, y, t, group_by=NULL, col=NULL, xlab="", ylab="", tlab="", ...) {
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
traj3d.close <- function() {
  rgl.close()
}


#' Visualize individual's trajectories.
#' 
#' This function plots a trajectory of a specific user as a weighted
#' graph. Each node represents a stay point whose size indicates the
#' (log) length of dwelling time. Each directed edge means the existence
#' transition between stay points and its width indicates the (log)
#' transition frequencies.
#' @export
#' @examples
#' data(movement)
#' 
#' user <- subset(movement, id==20)
#' plot_traj_graph(user$loc, user$time)
plot_traj_graph <- function(loc, time, ...) {
  library(igraph)
  user <- data.frame(loc=loc, time=time)
  stays <- cal_place_dwelling(user$loc, user$time)
  cut.off <- sqrt(median(stays$dwelling))
  stays.cut <- stays[stays$dwelling > cut.off, ]
  user.cut <- subset(user, user$loc %in% stays.cut$loc)
  movs.cut <- flowmap(1, user.cut$loc, user.cut$time)
  
  g <- graph.data.frame(movs.cut, vertices=stays.cut, directed = TRUE)
  V(g)$size <- log(V(g)$dwelling + 1) * 3
  V(g)$label <- NA
  V(g)$frame.color <- NA
  pal <- brewer.pal(12, name='Set3')
  V(g)$community <- optimal.community(g)$membership
  V(g)$color <- pal[vbin(V(g)$community, 10)]
  E(g)$arrow.size <- .2
  E(g)$curved <- .1
  E(g)$width <- log(E(g)$total+1) * 2
  plot(g, layout=layout.kamada.kawai, ...)
}

# Merged by the same locations
merge_dwelling_session <- function(loc, time) {
  df <- data.frame(loc, time)
  df %>% 
    mutate(grp=cumsum(c(TRUE, diff(loc) != 0))) %>%
    group_by(grp, loc) %>%
    summarise(stime=min(time), etime=max(time))
}

#' Calculate dwelling period by averaging dwelling
#' time between different consecutive locations
#' @export
cal_place_dwelling <- function(loc, time) {
  xt <- merge_dwelling_session(loc, time)
  xt$dwelling <- xt$etime - xt$stime
  L <- nrow(xt)
  delta <- 0.5 * (xt$stime[2:L] - xt$etime[1:L-1])
  xt$dwelling <- xt$dwelling + c(delta, 0) + c(0, delta)
  df <- data.frame(loc=xt$loc, dwelling=xt$dwelling)
  df %>% group_by(loc) %>% summarise(dwelling=sum(dwelling))
}