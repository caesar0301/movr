% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{melt.time}
\alias{melt.time}
\title{Melt time into parts}
\usage{
\method{melt}{time}(epoch, tz = "Asia/Shanghai")
}
\arguments{
\item{epoch}{the UNIX epoch timestamp in seconds}

\item{tz}{the time zone string}
}
\value{
several fields (indexed by order) of given timestamp:
 year, month, day, hour, minute, second,
 day of week (dow),
 day of year (doy),
 week of month (wom),
 week of year (woy),
 quarter of year (qoy)
}
\description{
Melt time into parts
}
