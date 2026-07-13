source("data_loader.R")
source("graph_builder.R")
source("bridge_finder.R")
source("chain_analysis.R")
source("visualize.R")

csv_path <- "Telefonemas.csv"
network_html_path <- "network.html"

calls <- load_calls(csv_path)

g <- build_call_graph(calls)
g <- detect_communities(g)
cat("=== Communities detected ===\n")
print(table(Community = V(g)$community))

bridges <- find_bridges(g)
cat("\n=== Bridge numbers connecting multiple communities ===\n")
print(bridges)

chain_results <- bucket_gaps(run_chain_tests(bridges$number, calls))
cat("\n=== Chaining test results ===\n")
print(chain_results)

plot_network(g, bridges, network_html_path)
cat("\nInteractive network saved to", network_html_path, "\n")
