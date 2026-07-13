load_calls <- function(path) {
  # source file is Windows-1252, not UTF-8 — without this, accented columns break
  calls <- read.csv(path, fileEncoding = "windows-1252")
  calls$DataHora <- as.POSIXct(calls$Data.e.Hora, format = "%m/%d/%Y %H:%M")
  calls
}