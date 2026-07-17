library(htmltools)

format_minutes <- function(mins) {
  if (is.na(mins)) return("N/A")
  if (mins < 60) return(paste0(round(mins), " min"))
  if (mins < 1440) return(paste0(round(mins / 60, 1), " hours"))
  paste0(round(mins / 1440, 1), " days")
}

generate_report <- function(g, bridges, chain_results, path = "report.html") {
  gap <- attr(bridges, "gap")
  community_sizes <- table(V(g)$community)

  bridge_rows <- lapply(seq_len(nrow(bridges)), function(i) {
    number <- bridges$number[i]
    chain <- chain_results[chain_results$bridge == number, ]
    significant <- chain$p_value < 0.05
    interpretation <- if (significant) {
      "Statistically significant: call timing changes depending on who it's talking to, consistent with deliberate contact-switching."
    } else {
      "Not statistically significant: no strong evidence this number behaves differently when switching contacts."
    }

    tags$tr(
      tags$td(number),
      tags$td(paste0(round(bridges$same_community_pct[i], 1), "%")),
      tags$td(round(bridges$betweenness[i])),
      tags$td(format_minutes(chain$same_contact_median_min)),
      tags$td(format_minutes(chain$switch_median_min)),
      tags$td(sprintf("%.3f", chain$p_value)),
      tags$td(interpretation)
    )
  })

  html <- tagList(
    tags$head(
      tags$meta(charset = "utf-8"),
      tags$title("Call Network Analysis Report"),
      tags$style("
        body { font-family: Arial, sans-serif; margin: 40px; color: #222; line-height: 1.5; }
        h1 { border-bottom: 2px solid #1f77b4; padding-bottom: 8px; }
        h2 { color: #1f77b4; margin-top: 40px; }
        table { border-collapse: collapse; width: 100%; margin-top: 12px; }
        th, td { border: 1px solid #ddd; padding: 8px 10px; text-align: left; font-size: 14px; }
        th { background: #1f77b4; color: white; }
        tr:nth-child(even) { background: #f7f7f7; }
        .warning { background: #fff3cd; border: 1px solid #ffe08a; padding: 12px; border-radius: 4px; }
        .summary { display: flex; gap: 24px; margin: 20px 0; }
        .stat { background: #f0f4f8; padding: 16px 24px; border-radius: 6px; }
        .stat .num { font-size: 28px; font-weight: bold; color: #1f77b4; }
      ")
    ),
    tags$body(
      tags$h1("Call Network Analysis Report"),
      tags$p(
        "Summary of numbers, communities, and bridge numbers found in the call records, ",
        "with a statistical check for deliberate chaining behavior. See ",
        tags$a(href = "network.html", "network.html"), " for the interactive graph."
      ),

      tags$div(class = "summary",
        tags$div(class = "stat", tags$div(class = "num", length(V(g))), "numbers analyzed"),
        tags$div(class = "stat", tags$div(class = "num", length(community_sizes)), "communities detected"),
        tags$div(class = "stat", tags$div(class = "num", nrow(bridges)), "bridge numbers found")
      ),

      if (!is.na(gap) && gap < 20) tags$div(class = "warning",
        tags$strong("Note: "),
        sprintf(
          "The separation between bridge and non-bridge numbers was weak in this dataset (gap of %.1f percentage points). Bridge classification below may be less reliable and should be corroborated with other evidence.",
          gap
        )
      ),

      tags$h2("Bridge Numbers"),
      tags$p(
        "A bridge is a number that, if removed, would split the call network into separate groups — ",
        "it is the only connection between two communities. A statistically significant result means the ",
        "number's call timing pattern changes depending on who it calls next, which can indicate deliberate ",
        "switching between contacts rather than coincidence."
      ),
      tags$table(
        tags$tr(
          tags$th("Number"), tags$th("% Calls Within Own Community"), tags$th("Betweenness"),
          tags$th("Median Gap (Same Contact)"), tags$th("Median Gap (Switch Contact)"),
          tags$th("p-value"), tags$th("Interpretation")
        ),
        bridge_rows
      ),

      tags$h2("Communities"),
      tags$table(
        tags$tr(tags$th("Community"), tags$th("Size (numbers)")),
        lapply(seq_along(community_sizes), function(i) {
          tags$tr(tags$td(names(community_sizes)[i]), tags$td(community_sizes[i]))
        })
      )
    )
  )

  save_html(html, path)
}
