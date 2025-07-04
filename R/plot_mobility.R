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
#' users <- subset(movement, id %in% c(23, 20))
#' users <- dplyr::mutate(users, time = time/86400 - min(time/86400))
#' users <- dplyr::filter(users, time <= 30)
#' \dontrun{
#' plot_traj3d(users$lon, users$lat, users$time,
#'  group_by=users$id, col=c('royalblue', 'orangered'))
#' 
#' invisible(readline(prompt="Press [enter] to continue"))
#' traj3d.close()
#' }
plot_traj3d <- function(x, y, t, group_by=NULL, col=NULL, xlab="", ylab="", tlab="", ...) {
  if (!requireNamespace("rgl", quietly = TRUE)) {
    stop("Package 'rgl' is required for this function. Please install it with: install.packages('rgl')")
  }
  if (!requireNamespace("deldir", quietly = TRUE)) {
    stop("Package 'deldir' is required for this function.")
  }
  
  stopifnot(length(x) == length(y) && length(x) == length(t))
  
  #t <- strftime(as.POSIXct(t, origin="1970-01-01"), format="%m%d-%H:%M")
  
  rgl::par3d(windowRect=c(20,40,800,800), cex='0.8')
  rgl::rgl.clear()
  rgl::rgl.clear("lights")
  rgl::rgl.bg(color="white")
  rgl::rgl.viewpoint(theta = 40, phi = 10)
  rgl::rgl.light(theta = -15, phi = 30, viewpoint.rel=TRUE)
  
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
  
  rgl::plot3d(x, t, y, type='n', xlab=xlab, ylab=tlab, zlab=ylab, axes=FALSE, ...)
  
  for (g in unique(group_by)) {
    x0 = x[group_by==g]
    t0 = t[group_by==g]
    y0 = y[group_by==g]
    rgl::plot3d(x0, t0, y0, type='p', col=col[g], add=TRUE, ...)
    rgl::lines3d(x0, t0, y0, color=col[g], ...)
  }
  
  voronoi3d(x, y, group_by, col)
  
  # rgl::axes3d(edges=c("x--", "y--", "z"))
  # rgl::axes3d(lwd=0.7, xlen=8, ylen=10, zlen=8, col='black', marklen=40)
  
  rgl::axes3d(edges=c('z+-', 'x-+', 'y-+'),
         col='black', nticks=7, expand=1,
         labels = FALSE, tick = FALSE, ...)
}

#' Close RGL 3D device
#' 
#' Close the current RGL 3D device. This is a convenience function
#' that checks if the rgl package is available before closing.
#' 
#' @export
#' @examples
#' \dontrun{
#' # After creating a 3D plot with plot_traj3d
#' traj3d.close()
#' }
traj3d.close <- function() {
  if (!requireNamespace("rgl", quietly = TRUE)) {
    stop("Package 'rgl' is required for this function. Please install it with: install.packages('rgl')")
  }
  rgl::rgl.close()
}


#' Visualize individual's trajectories.
#' 
#' This function plots a trajectory of a specific user as a weighted
#' graph. Each node represents a stay point whose size indicates the
#' (log) length of dwelling time. Each directed edge means the existence
#' transition between stay points and its width indicates the (log)
#' transition frequencies.
#' 
#' @param loc A vector of location identifiers
#' @param time A vector of timestamps corresponding to each location
#' @param ... Additional arguments passed to plot function
#' @export
#' @examples
#' data(movement)
#' 
#' user <- subset(movement, id==20)
#' plot_traj_graph(user$loc, user$time)
plot_traj_graph <- function(loc, time, ...) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop("Package 'igraph' is required for this function.")
  }
  user <- data.frame(loc=loc, time=time)
  stays <- cal_place_dwelling(user$loc, user$time)
  cut.off <- sqrt(median(stays$dwelling))
  stays.cut <- stays[stays$dwelling > cut.off, ]
  user.cut <- subset(user, user$loc %in% stays.cut$loc)
  movs.cut <- flowmap(1, user.cut$loc, user.cut$time)
  
  g <- igraph::graph.data.frame(movs.cut, vertices=stays.cut, directed = TRUE)
  igraph::V(g)$size <- log(igraph::V(g)$dwelling + 1) * 3
  igraph::V(g)$label <- NA
  igraph::V(g)$frame.color <- NA
  if (requireNamespace("RColorBrewer", quietly = TRUE)) {
    pal <- RColorBrewer::brewer.pal(12, name='Set3')
  } else {
    pal <- rainbow(12)
  }
  igraph::V(g)$community <- igraph::optimal.community(g)$membership
  igraph::V(g)$color <- pal[vbin(igraph::V(g)$community, 10)]
  igraph::E(g)$arrow.size <- .2
  igraph::E(g)$curved <- .1
  igraph::E(g)$width <- log(igraph::E(g)$total+1) * 2
  plot(g, layout=igraph::layout.kamada.kawai, ...)
}

# Merged by the same locations
merge_dwelling_session <- function(loc, time) {
  df <- data.frame(loc, time)
  df %>% 
      dplyr::mutate(grp=cumsum(c(TRUE, diff(.data$loc) != 0))) %>%
  dplyr::group_by(.data$grp, .data$loc) %>%
  dplyr::summarise(stime=min(.data$time), etime=max(.data$time))
}

#' Calculate dwelling period by averaging dwelling
#' time between different consecutive locations
#' 
#' @param loc A vector of location identifiers
#' @param time A vector of timestamps corresponding to each location
#' @return A data frame with columns 'loc' and 'dwelling' containing the total dwelling time for each location
#' @export
cal_place_dwelling <- function(loc, time) {
  xt <- merge_dwelling_session(loc, time)
  xt$dwelling <- xt$etime - xt$stime
  L <- nrow(xt)
  delta <- 0.5 * (xt$stime[2:L] - xt$etime[1:L-1])
  xt$dwelling <- xt$dwelling + c(delta, 0) + c(0, delta)
  df <- data.frame(loc=xt$loc, dwelling=xt$dwelling)
  df %>% dplyr::group_by(.data$loc) %>% dplyr::summarise(dwelling=sum(.data$dwelling))
}