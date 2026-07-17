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

bridges <- find_bridges(g)

chain_results <- bucket_gaps(run_chain_tests(bridges$number, calls))

plot_network(g, bridges, network_html_path)
generate_report(g, bridges, chain_results, report_html_path)

cat("Done. Open", report_html_path, "for the findings and", network_html_path, "for the interactive graph.\n")
