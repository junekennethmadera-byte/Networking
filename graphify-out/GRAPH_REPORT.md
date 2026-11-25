# Graph Report - Liquidation2  (2026-10-21)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 58 nodes · 69 edges · 7 communities
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.5)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `778a8276`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- server.js
- package.json
- api
- Liquidation Flow Frontend
- Cash Advance Requests Table
- Profiles Table
- Liquidations Table

## God Nodes (most connected - your core abstractions)
1. `Liquidation Flow Frontend` - 13 edges
2. `Cash Advance Requests Table` - 9 edges
3. `api()` - 6 edges
4. `Liquidations Table` - 6 edges
5. `Profiles Table` - 5 edges
6. `Row Level Security` - 4 edges
7. `json()` - 3 edges
8. `server` - 3 edges
9. `scripts` - 3 edges
10. `Workflow Actions` - 3 edges

## Surprising Connections (you probably didn't know these)
- `Liquidation Flow Frontend` --shares_data_with--> `Liquidation Files Table`  [EXTRACTED]
  public/cash_advance_supabase.html → database/supabase_schema.sql
- `Liquidation Flow Frontend` --references--> `Cash Advance Documents Storage`  [EXTRACTED]
  public/cash_advance_supabase.html → database/supabase_schema.sql
- `Liquidation Flow Frontend` --references--> `Audit Logs Table`  [EXTRACTED]
  public/cash_advance_supabase.html → database/supabase_schema.sql
- `Liquidation Flow Frontend` --shares_data_with--> `Liquidations Table`  [EXTRACTED]
  public/cash_advance_supabase.html → database/supabase_schema.sql
- `Liquidation Flow Frontend` --shares_data_with--> `Profiles Table`  [EXTRACTED]
  public/cash_advance_supabase.html → database/supabase_schema.sql

## Import Cycles
- None detected.

## Communities (7 total, 0 thin omitted)

### Community 0 - "server.js"
Cohesion: 0.11
Nodes (10): crypto, DATABASE_ROOT, { DatabaseSync }, db, fs, http, path, PORT (+2 more)

### Community 1 - "package.json"
Cohesion: 0.18
Nodes (10): description, engines, node, main, name, private, scripts, dev (+2 more)

### Community 2 - "api"
Cohesion: 0.40
Nodes (6): api(), body(), json(), nextReference(), safeUser(), server

### Community 3 - "Liquidation Flow Frontend"
Cohesion: 0.25
Nodes (8): Audit Logs Table, Liquidation Flow Frontend, Profile Loading, Cash Advance Request Creation, Requester Portal, Staff Portal, Supabase Authentication, Supabase Data Loading

### Community 4 - "Cash Advance Requests Table"
Cohesion: 0.40
Nodes (4): Cash Advance Reference Generation, Requester Role, Cash Advance Requests Table, Treasurer Role

### Community 5 - "Profiles Table"
Cohesion: 0.40
Nodes (5): Automatic Profile Provisioning, Profiles Table, Application Roles, Row Level Security, Cash Advance Documents Storage

### Community 6 - "Liquidations Table"
Cohesion: 0.50
Nodes (4): Financial Secretary Role, Liquidation Files Table, Liquidations Table, Workflow Actions

## Knowledge Gaps
- **13 isolated node(s):** `Requester Portal`, `Staff Portal`, `Supabase Authentication`, `Profile Loading`, `Supabase Data Loading` (+8 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 40 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Liquidation Flow Frontend` connect `Liquidation Flow Frontend` to `Cash Advance Requests Table`, `Profiles Table`, `Liquidations Table`?**
  _High betweenness centrality (0.085) - this node is a cross-community bridge._
- **What connects `Requester Portal`, `Staff Portal`, `Supabase Authentication` to the rest of the system?**
  _13 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `server.js` be split into smaller, more focused modules?**
  _Cohesion score 0.10526315789473684 - nodes in this community are weakly interconnected._
- **Why does `Cash Advance Requests Table` connect `Cash Advance Requests Table` to `Liquidation Flow Frontend`, `Profiles Table`, `Liquidations Table`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **Why does `Profiles Table` connect `Profiles Table` to `Liquidation Flow Frontend`, `Cash Advance Requests Table`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._