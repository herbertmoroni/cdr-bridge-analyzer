load_calls <- function(path) {
  calls <- read.csv(path, stringsAsFactors = FALSE)
  calls$timestamp <- as.POSIXct(calls$timestamp, format = "%Y-%m-%d %H:%M:%S")
  calls
}
