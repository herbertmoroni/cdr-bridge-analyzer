get_contacts <- function(hub, calls) {
  involved <- calls[calls$Origem == hub | calls$Destino == hub, ]
  ifelse(involved$Origem == hub, involved$Destino, involved$Origem) |> unique()
}

find_bridges <- function(hubs, calls) {
  contacts_by_hub <- list()
  for (h in hubs) {
    contacts_by_hub[[as.character(h)]] <- get_contacts(h, calls)
  }

  bridges <- list()
  for (i in 1:(length(hubs) - 1)) {
    for (j in (i + 1):length(hubs)) {
      h1 <- hubs[i]
      h2 <- hubs[j]
      shared <- intersect(contacts_by_hub[[as.character(h1)]], contacts_by_hub[[as.character(h2)]])
      shared <- setdiff(shared, hubs)  # exclude direct hub-to-hub calls, not real bridges
      if (length(shared) > 0) {
        bridges[[paste(h1, h2)]] <- shared
      }
    }
  }
  bridges
}