source("data_loader.R")
source("graph_builder.R")
source("bridge_finder.R")
source("chain_analysis.R")
source("visualize.R")
source("report.R")

csv_path <- "Telefonemas.csv"
network_html_path <- "network.html"
report_html_path <- "report.html"

calls <- load_calls(csv_path)

g <- build_call_graph(calls)
g <- detect_communities(g)

bridge_result <- find_bridges(g)
bridges <- bridge_result$bridges

chain_results <- bucket_gaps(run_chain_tests(bridges$number, calls))

plot_network(g, bridges, network_html_path)
generate_report(g, bridges, bridge_result$gap, chain_results, report_html_path)

cat("=== Communities ===\n")
print(table(Community = V(g)$community))

cat("\n=== Bridges ===\n")
print(bridges)

cat("\n=== Chaining test results ===\n")
print(chain_results[, c("bridge", "n_calls", "p_value", "same_contact_bucket", "switch_bucket")])

if (!is.na(bridge_result$gap) && bridge_result$gap < 20) {
  cat("\nWarning: weak bridge/hub separation (gap:", round(bridge_result$gap, 1), "pp) — see report for detail.\n")
}

cat("\nDone. Open", report_html_path, "for the findings and", network_html_path, "for the interactive graph.\n")
