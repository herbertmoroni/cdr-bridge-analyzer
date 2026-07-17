suppressPackageStartupMessages(library(igraph))

build_call_graph <- function(calls) {
  edges <- calls[, c("from", "to")]
  g <- graph_from_data_frame(edges, directed = FALSE)
  E(g)$weight <- 1
  simplify(g, edge.attr.comb = list(weight = "sum"))
}

detect_communities <- function(g) {
  communities <- cluster_louvain(g, weights = E(g)$weight)
  V(g)$community <- membership(communities)
  g
}
