get_bridge_calls <- function(bridge, calls) {
  calls <- calls[order(calls$DataHora), ]
  involved <- calls[calls$Origem == bridge | calls$Destino == bridge, ]
  involved$Other <- ifelse(involved$Origem == bridge, involved$Destino, involved$Origem)
  involved
}

tag_transitions <- function(bridge_calls) {
  n <- nrow(bridge_calls)
  # [-1] drops the first row, [-n] drops the last — lines the two vectors up
  # so index i compares call i to call i+1, giving one gap per consecutive pair
  gap_minutes <- as.numeric(difftime(bridge_calls$DataHora[-1], bridge_calls$DataHora[-n], units = "mins"))
  switched <- bridge_calls$Other[-1] != bridge_calls$Other[-n]
  data.frame(gap_minutes = gap_minutes, switched = factor(switched))
}

test_chaining <- function(bridge, calls) {
  transitions <- tag_transitions(get_bridge_calls(bridge, calls))
  wilcox.test(gap_minutes ~ switched, data = transitions)
}

run_chain_tests <- function(bridges, calls) {
  bridge_numbers <- unique(unlist(bridges))

  results <- data.frame()
  for (bridge in bridge_numbers) {
    transitions <- tag_transitions(get_bridge_calls(bridge, calls))
    test <- wilcox.test(gap_minutes ~ switched, data = transitions)

    same_median <- median(transitions$gap_minutes[transitions$switched == FALSE])
    switch_median <- median(transitions$gap_minutes[transitions$switched == TRUE])

    results <- rbind(results, data.frame(
      bridge = bridge,
      n_calls = nrow(transitions) + 1,
      same_hub_median_min = same_median,
      switch_median_min = switch_median,
      p_value = test$p.value
    ))
  }
  results
}

library(dplyr)

bucket_gaps <- function(results_table) {
  results_table |>
    mutate(
      same_hub_bucket = case_when(
        same_hub_median_min < 5     ~ "Immediate",
        same_hub_median_min < 1440  ~ "Same-day",
        TRUE                        ~ "Later"
      ),
      switch_bucket = case_when(
        switch_median_min < 5     ~ "Immediate",
        switch_median_min < 1440  ~ "Same-day",
        TRUE                      ~ "Later"
      )
    )
}

library(parallel)

run_chain_tests_distributed <- function(bridges, calls) {
  bridge_numbers <- unique(unlist(bridges))

  cl <- makeCluster(length(bridge_numbers))
  clusterExport(cl, varlist = c("calls", "get_bridge_calls", "tag_transitions"))

  results <- parLapply(cl, bridge_numbers, function(bridge) {
    transitions <- tag_transitions(get_bridge_calls(bridge, calls))
    test <- wilcox.test(gap_minutes ~ switched, data = transitions)
    data.frame(
      bridge = bridge,
      n_calls = nrow(transitions) + 1,
      same_hub_median_min = median(transitions$gap_minutes[transitions$switched == FALSE]),
      switch_median_min = median(transitions$gap_minutes[transitions$switched == TRUE]),
      p_value = test$p.value
    )
  })

  stopCluster(cl)
  do.call(rbind, results)
}