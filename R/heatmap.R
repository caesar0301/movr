#' @export
heatmap.levels <- function(z, nlevels=10) {
  # Generate color breaks
  brks <- classIntervals(z, nlevels, style='equal')
  brks$brks
}

#' Heatmap of xyz data
#' 
#' Visualize the xyz data in a 2d heatmap.
#' 
#' @param x,y the coordinates of each z value.
#' @param z the observed value for each (x,y) point.
#' @param nx,ny the number of bins in x and y dimension, used by \code{\link{vbin.grid}}.
#' @param na replacement for NA value in matrix bins, used by \code{\link{vbin.grid}}.
#' @param nlevels the number of colorful stages to plot, see `filled.contour`.
#' @param levels a numeric vector to indicate the colorful stages, see `filled.contour`.
#' @param colors a vector of color names or hex values, see `colorRampPalette`.
#' @param bias a positive number. Higher values give more widely spaced colors at the high end, see `colorRampPalette`.
#' @param ... other parameters sent to `filled.contour`.
#' @export
plot.heatmap <- function(x, y, z, nx=100, ny=100, na=0, nlevels=10, levels=NULL,
                         colors=rev(brewer.pal(11, "Spectral")), bias=1, ...) {
  # Create color palette
  col.pal <- colorRampPalette(colors, bias=bias)
  
  # Generate 2d heatmap from xyz data
  mat <- vbin_grid(x, y, z, na=na, nx=nx, ny=ny)
  
  # Obtain x and y coordinates for each bin on a 2d surface
  x <- as.numeric(rownames(mat))
  y <- as.numeric(colnames(mat))
  
  is_empty <- function(x) { is.na(x) | is.null(x) }
  
  if(is.null(levels)) {
    mv <- unlist(mat)
    if(is_empty(na))
      mv <- mv[!is_empty(mv)]
    levels <- heatmap.levels(mv, nlevels)
  }
  
  # Plot contour-style heatmap
  filled.contour(x, y, mat, levels=levels, color.palette=col.pal, ...)
  
  invisible(list(data=mat, levels=levels))
}