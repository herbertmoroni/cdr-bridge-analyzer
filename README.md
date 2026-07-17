# CDR Bridge Analyzer

Finds "bridge" numbers connecting otherwise-separate call networks in a call
detail record (CDR) export, and tests whether each bridge shows relay/pass-
through behavior — calling a different party shortly after being called,
rather than the more usual pattern.

## How it works

1. Builds a call graph from the CDR (numbers = nodes, calls = edges,
   weighted by call count between each pair).
2. Runs community detection (Louvain) to automatically discover separate
   call networks — no need to manually identify "hub" numbers first.
3. Flags **bridges**: numbers that are graph articulation points (removing
   them would split the network) *and* whose contacts are mostly outside
   their own community. Hubs are also articulation points, but their
   contacts stay mostly within their own community — so the same-community
   percentage separates hubs from bridges. Rather than a fixed cutoff, the
   threshold is calibrated per dataset: it sorts that percentage across all
   articulation points, finds the largest gap between consecutive values,
   and sets the threshold at that gap's midpoint. A warning appears in the
   report if the gap is under 20 percentage points, meaning the split is
   weak for that dataset. Results are ranked by betweenness centrality.
4. For each bridge, runs a Wilcoxon rank-sum test comparing the time gap
   before a call to the *same* contact vs. before *switching* to a different
   contact. A short switch-gap relative to same-contact-gap is a signature of
   relaying (receive, then immediately forward).
5. Writes an interactive network visualization to `network.html` — nodes
   colored by community, bridges shown as red triangles. Open it in any
   browser; drag, zoom, and click a node to see its details.
6. Writes `report.html` — a summary page with community/bridge counts, the
   ranked bridge table (with chaining test results and interpretation), and
   the calibration warning if the split was weak.

## Input format

The CSV must have these columns (any extra columns are ignored):

| column      | meaning                              | format                |
|-------------|---------------------------------------|------------------------|
| `from`      | originating number                    | numeric                |
| `to`        | receiving number                      | numeric                |
| `timestamp` | when the call happened                | `YYYY-MM-DD HH:MM:SS`  |
| `duration`  | call length in seconds                | numeric                |

Example:

```csv
from,to,timestamp,duration
1195646235,1187037061,2012-05-01 08:11:00,22
1195646235,1187037061,2012-05-01 09:03:00,190
```

If your carrier export uses different column names, a different date format,
or a different encoding, rename/reformat it to match before running the
tool — this keeps the loader simple and predictable rather than guessing at
carrier-specific quirks.

## Running it

```
Rscript main.R
```

Edit the `csv_path` variable at the top of `main.R` to point at a different
file.

### Dependencies

```r
install.packages(c("igraph", "visNetwork", "dplyr", "htmltools"))
```

## Output

- `report.html`: summary of numbers/communities/bridges found, the ranked
  bridge table (% calls within own community, betweenness, median gap when
  calling the same contact vs. switching, and the test's p-value — a low
  p-value means the difference is unlikely to be chance), and a warning if
  the bridge/non-bridge split was weak for this dataset.
- `network.html` (plus a sibling `network_files/` folder it depends on —
  keep them together): interactive visualization of the call network,
  linked from `report.html`.
