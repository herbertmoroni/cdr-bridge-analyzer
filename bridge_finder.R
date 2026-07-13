library(igraph)

# A bridge is a number whose contacts span 2+ communities — the graph-theoretic
# generalization of "a contact shared between two hand-picked hubs".
find_bridges <- function(g) {
  scores <- betweenness(g, weights = E(g)$weight)

  n_communities_touched <- sapply(V(g), function(v) {
    neighbor_communities <- V(g)$community[neighbors(g, v)]
    length(unique(neighbor_communities))
  })

  bridge_idx <- which(n_communities_touched >= 2)
  bridges <- data.frame(
    number = V(g)$name[bridge_idx],
    n_communities = n_communities_touched[bridge_idx],
    betweenness = scores[bridge_idx],
    stringsAsFactors = FALSE
  )
  bridges[order(-bridges$betweenness), ]
}
