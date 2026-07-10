# fileEncoding matters here: this CSV was saved as Windows-1252, not UTF-8.
# Without it, the "Duração" column name comes through mangled.
calls <- read.csv("Telefonemas_TodasTelefonemas.csv", fileEncoding = "windows-1252")

str(calls)
head(calls)