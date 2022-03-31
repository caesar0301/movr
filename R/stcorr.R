#' Calculate pairwise distances in a 2D region
#' 
#' Given a random field defined by (x, y) and observation value z, this function
#' calculates the distance between each location pair and appends original observation
#' values into the same row. The output can be exploited to calculate spatial correlations.
#' Note that only Euclidean distance is supported merely for this time.
#' 
#' @param x,y the coordinates of given random field
#' @param z the observation value for each point (x,y)
#' @return the data frame of c('r', 'z1', 'z2')
#' @seealso \code{\link{spatial.corr}}
#' @export
pairwise.dist <- function(x, y, z){
  df <- data.frame(x=x, y=y, z=z)
  euc.dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))
  
  blocks <- nrow(df)
  z.mean <- mean(df$z, na.rm=TRUE)
  z.var <- var(df$z, na.rm=TRUE)
  
  do.call(rbind, mclapply(seq(1, blocks), function(i){
    do.call(rbind, mclapply(seq(i, blocks), function(j){
      data.frame(
        r = euc.dist(df[i, c("x","y")], df[j, c("x","y")]),
        z1 = df[i, "z"],
        z2 = df[j, "z"])
    }))
  }))
}

#' Calculate spatial correlation of a 2D region
#' 
#' @param x,y the coordinates of given random field
#' @param z the observation value for each point (x,y)
#' @param beta the step value to map distances into bins
#' @param corr.method the name of function to calculate correlation, one of c("pearson", "kendall", "spearman")
#' @return r distance between a pair of locations
#' @return n the number of location pairs for specific distance
#' @return corr the correlation value for specific distance
#' @seealso \code{\link{pairwise.dist}}
#' @export
spatial.corr <- function(x, y, z, beta=0.05, corr.method='pearson') {
  pairwise.dist(x, y, z) %>% mutate(
    r.int = findInterval(r, seq(min(r), max(r), by=beta))) %>%
    group_by(r.int) %>%
    dplyr::summarise(
      r = mean(r),
      n = length(z1),
      corr = cor(z1, z2, method=corr.method)
    ) %>% filter(!is.na(corr)) %>% select(-r.int)
}