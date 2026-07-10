# fileEncoding matters here: this CSV was saved as Windows-1252, not UTF-8.
# Without it, the "Duração" column name comes through mangled.
calls <- read.csv("Telefonemas.csv", fileEncoding = "windows-1252")

str(calls)
head(calls)

# Turn the text timestamp into a real date-time value
calls$DataHora <- as.POSIXct(calls$Data.e.Hora, format = "%m/%d/%Y %H:%M")

# The six hub numbers we already identified as the dominant networks
hubs <- c(1187037061, 1189015992, 1198140528, 1199274481, 1199540941, 1199586672)

# For one hub number, return every number it exchanged calls with
get_contacts <- function(hub) {
  involved <- calls[calls$Origem == hub | calls$Destino == hub, ]
  other <- ifelse(involved$Origem == hub, involved$Destino, involved$Origem)
  unique(other)
}

# Build a contact list per hub, keyed by hub number
contacts_by_hub <- list()
for (h in hubs) {
  contacts_by_hub[[as.character(h)]] <- get_contacts(h)
}

# Compare every pair of hubs, looking for numbers they both contacted
for (i in 1:(length(hubs) - 1)) {
  for (j in (i + 1):length(hubs)) {
    h1 <- hubs[i]
    h2 <- hubs[j]
    shared <- intersect(contacts_by_hub[[as.character(h1)]], contacts_by_hub[[as.character(h2)]])
    shared <- setdiff(shared, hubs)
    if (length(shared) > 0) {
      cat("Hubs", h1, "&", h2, "share contact(s):", shared, "\n")
    }
  }
}