source("data_loader.R")
source("bridge_finder.R")
source("chain_analysis.R")

hubs <- c(1187037061, 1189015992, 1198140528, 1199274481, 1199540941, 1199586672)

calls <- load_calls("Telefonemas.csv")
bridges <- find_bridges(hubs, calls)

cat("=== Bridge numbers connecting multiple call networks ===\n")
print(bridges)

results <- bucket_gaps(run_chain_tests_distributed(bridges, calls))
cat("\n=== Chaining test results ===\n")
print(results)