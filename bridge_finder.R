library(igraph)

# A bridge is a cut vertex (articulation point) whose contacts are mostly
# outside its own community. Hubs are also cut vertices, but their contacts
# stay mostly within their own community. Instead of a fixed cutoff, the
# threshold is calibrated per dataset: sort same-community percentages among
# all cut vertices, find the largest gap between consecutive values, and set
# the threshold at that gap's midpoint — self-calibrating rather than tuned
# to one dataset's numbers.
find_adaptive_threshold <- function(pcts) {
  if (length(pcts) < 2) return(list(threshold = NA, gap = NA))
  sorted_pcts <- sort(pcts)
  gaps <- diff(sorted_pcts)
  max_gap_idx <- which.max(gaps)
  list(
    threshold = mean(sorted_pcts[max_gap_idx:(max_gap_idx + 1)]),
    gap = gaps[max_gap_idx]
  )
}

find_bridges <- function(g) {
  cut_vertices <- articulation_points(g)
  cut_ids <- as.numeric(cut_vertices)

  same_community_pct <- sapply(cut_ids, function(vid) {
    own_community <- V(g)$community[vid]
    neighbor_communities <- V(g)$community[neighbors(g, vid)]
    100 * sum(neighbor_communities == own_community) / length(neighbor_communities)
  })

  scores <- betweenness(g, weights = E(g)$weight)
  adaptive <- find_adaptive_threshold(same_community_pct)

  is_bridge <- !is.na(adaptive$threshold) & same_community_pct <= adaptive$threshold

  all_cut_vertices <- data.frame(
    number = V(g)$name[cut_ids],
    same_community_pct = same_community_pct,
    betweenness = scores[cut_ids],
    is_bridge = is_bridge,
    stringsAsFactors = FALSE
  )

  list(
    bridges = all_cut_vertices[all_cut_vertices$is_bridge, c("number", "same_community_pct", "betweenness")],
    gap = adaptive$gap
  )
}
