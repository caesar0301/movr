#' movr: inspecting human mobility with R
#'
#' A package targeting at analyzing, modeling, and visualizing
#' human mobility from temporal and spatial perspectives.
#'
#' @name movr
#' @docType package
#' @useDynLib movr
#' 
#' @importFrom dplyr group_by summarise mutate filter left_join distinct do select .data id
#' @importFrom tidyr unite separate
#' @importFrom magrittr %>%
#' @importFrom igraph graph.data.frame V E optimal.community layout.kamada.kawai
#' @importFrom graphics plot lines par axis rect text title filled.contour curve
#' @importFrom grDevices col2rgb colorRampPalette colors rainbow rgb2hsv
#' @importFrom stats cor median var
#' @importFrom methods .hasSlot
"_PACKAGE"
