#' Draw a DAG
#'
#' Make a simple drawing of a DAG.
#'
#' @details See the igraph package for more details.
#'
#' @param DAG The DAG to draw
#' @param \ldots Additional arguments to plot.igraph()
#'
#' @details By default, edges are not drawn to hidden nodes. To show the hidden
#' nodes, use the argument `show_hidden=TRUE`.
#'
#' @examples
#' dag_draw(dag03)
#' @export
dag_draw <- function(DAG, ...) {
  dots <- list(...)
  defaults <- list(vertex.size=40, vertex.color=NA,
                   vertex.shape="circle",
                   vertex.label.cex=2,
                   vertex.label.family="Courier",
                   vertex.frame.color=NA,
                   layout=igraph::layout_nicely)
  if ("seed" %in% names(dots)) {
    set.seed(dots$seed)
    dots$seed <- NULL
  }
  # override defaults or add new arguments
  for (nm in names(dots)) {
    defaults[[nm]] <- dots[[nm]]
  }

  reveal <- FALSE # default
  if ("show_hidden" %in% names(dots) ) reveal = dots$show_hidden

  ig <- dag_to_igraph(DAG, show_hidden=reveal)
  par(mai=c(0,0,0,0)) # have the graph fill the frame
  do.call(plot, c(list(ig), defaults))
}


