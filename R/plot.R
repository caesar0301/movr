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
axis.minor.ticks <- function(ax, n, lab=TRUE, tick.ratio=0.5, mn, mx,...){
  lims <- par("usr")
  if(ax %in% c(1,3)) lims <- lims[1:2] else lims[3:4]
  
  # require(squash)
  major.ticks <- prettyInt(lims)
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