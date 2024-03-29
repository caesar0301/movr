% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stcorr.R
\name{spatial.corr}
\alias{spatial.corr}
\title{Calculate spatial correlation of a 2D region}
\usage{
spatial.corr(x, y, z, beta = 0.05, corr.method = "pearson")
}
\arguments{
\item{x, y}{the coordinates of given random field}

\item{z}{the observation value for each point (x,y)}

\item{beta}{the step value to map distances into bins}

\item{corr.method}{the name of function to calculate correlation, one of c("pearson", "kendall", "spearman")}
}
\value{
r distance between a pair of locations

n the number of location pairs for specific distance

corr the correlation value for specific distance
}
\description{
Calculate spatial correlation of a 2D region
}
\seealso{
\code{\link{pairwise.dist}}
}
