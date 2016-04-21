#' @export
plot.mobility.graph <- function(loc, time, ...) {
  library(RColorBrewer)
  library(igraph)
  
  place_dwelling <- function(x, t) {
    xt <- compress_mov(x=x, t=t)
    xt$dwelling <- xt$etime - xt$stime
    
    L <- nrow(xt)
    delta <- 0.5 * (xt$stime[2:L] - xt$etime[1:L-1])
    xt$dwelling <- xt$dwelling + c(delta, 0) + c(0, delta)
    
    df <- data.frame(loc=xt$loc, dwelling=xt$dwelling)
    df %>% group_by(loc) %>% summarise(dwelling=sum(dwelling))
  }
  
  user <- data.frame(loc=loc, time=time)
  
  stays <- place_dwelling(user$loc, user$time)
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
