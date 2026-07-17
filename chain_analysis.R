get_bridge_calls <- function(bridge, calls) {
  bridge <- as.numeric(bridge)
  calls <- calls[order(calls$timestamp), ]
  involved <- calls[calls$from == bridge | calls$to == bridge, ]
  involved$other <- ifelse(involved$from == bridge, involved$to, involved$from)
  involved
}

tag_transitions <- function(bridge_calls) {
  n <- nrow(bridge_calls)
  # [-1] drops the first row, [-n] drops the last — lines the two vectors up
  # so index i compares call i to call i+1, giving one gap per consecutive pair
  gap_minutes <- as.numeric(difftime(bridge_calls$timestamp[-1], bridge_calls$timestamp[-n], units = "mins"))
  switched <- bridge_calls$other[-1] != bridge_calls$other[-n]
  data.frame(gap_minutes = gap_minutes, switched = factor(switched))
}

run_chain_tests <- function(bridges, calls) {
  results <- data.frame()
  for (bridge in bridges) {
    transitions <- tag_transitions(get_bridge_calls(bridge, calls))
    test <- wilcox.test(gap_minutes ~ switched, data = transitions)

    same_median <- median(transitions$gap_minutes[transitions$switched == FALSE])
    switch_median <- median(transitions$gap_minutes[transitions$switched == TRUE])

    results <- rbind(results, data.frame(
      bridge = bridge,
      n_calls = nrow(transitions) + 1,
      same_contact_median_min = same_median,
      switch_median_min = switch_median,
      p_value = test$p.value
    ))
  }
  results
}
