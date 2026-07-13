library(igraph)

# A bridge is a cut vertex (removing it splits the graph) whose contacts are
# mostly outside its own community. Hubs are also cut vertices — removing one
# disconnects its own peripheral contacts — but a hub's neighbors are mostly
# within its own community, while a real bridge's are mostly split across
# communities. Empirically: hubs run 87.5-100% same-community, bridges 33-50%.
find_bridges <- function(g) {
  cut_vertices <- as.integer(articulation_points(g))

  same_community_ratio <- sapply(V(g), function(v) {
    nbrs <- neighbors(g, v)
    mean(V(g)$community[nbrs] == V(g)$community[v])
  })

  scores <- betweenness(g, weights = E(g)$weight)

  bridge_idx <- intersect(cut_vertices, which(same_community_ratio <= 0.5))
  bridges <- data.frame(
    number = V(g)$name[bridge_idx],
    same_community_ratio = same_community_ratio[bridge_idx],
    betweenness = scores[bridge_idx],
    stringsAsFactors = FALSE
  )
  bridges[order(-bridges$betweenness), ]
}
