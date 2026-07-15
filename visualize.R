library(igraph)
library(visNetwork)
library(htmltools)

plot_network <- function(g, bridges, path = "network.html") {
  is_bridge <- V(g)$name %in% bridges$number

  nodes <- data.frame(
    id = V(g)$name,
    label = V(g)$name,
    group = paste0("Community ", V(g)$community),
    color = ifelse(is_bridge, "red", "#1f77b4"),
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
  edges <- data.frame(
    from = edge_df$from,
    to = edge_df$to,
    value = edge_df$weight,
    label = as.character(edge_df$weight)
  )

  widget <- visNetwork(nodes, edges, width = "100%", height = "100vh") |>
    visNodes(font = list(size = 14, strokeWidth = 3, strokeColor = "#ffffff")) |>
    visEdges(
      color = list(color = "#1f77b4", inherit = FALSE),
      font = list(size = 12, align = "middle", strokeWidth = 3, strokeColor = "#ffffff")
    ) |>
    visOptions(
      highlightNearest = list(enabled = TRUE, degree = list(from = 1, to = 1), algorithm = "hierarchical", labelOnly = FALSE),
      nodesIdSelection = TRUE
    ) |>
    visPhysics(solver = "forceAtlas2Based", stabilization = TRUE)

  widget <- htmlwidgets::prependContent(
    widget,
    tags$style("html, body, #htmlwidget_container { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; }")
  )

  visSave(widget, path, selfcontained = FALSE)
}
