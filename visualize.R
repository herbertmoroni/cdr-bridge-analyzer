library(igraph)
library(visNetwork)

plot_network <- function(g, bridges, path = "network.html") {
  palette <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
               "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf")
  community_colors <- palette[((V(g)$community - 1) %% length(palette)) + 1]
  is_bridge <- V(g)$name %in% bridges$number

  nodes <- data.frame(
    id = V(g)$name,
    label = V(g)$name,
    group = paste0("Community ", V(g)$community),
    color = ifelse(is_bridge, "red", community_colors),
    shape = ifelse(is_bridge, "triangle", "dot"),
    value = degree(g),
    title = paste0(
      "Number: ", V(g)$name,
      "<br>Community: ", V(g)$community,
      ifelse(is_bridge, "<br><b>Bridge</b>", "")
    ),
    stringsAsFactors = FALSE
  )

  edge_df <- igraph::as_data_frame(g, what = "edges")
  edges <- data.frame(from = edge_df$from, to = edge_df$to, value = edge_df$weight)

  visNetwork(nodes, edges) |>
    visNodes(font = list(size = 14, strokeWidth = 3, strokeColor = "#ffffff")) |>
    visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) |>
    visPhysics(solver = "forceAtlas2Based", stabilization = TRUE) |>
    visSave(path, selfcontained = FALSE)
}
