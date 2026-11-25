---
source_file: "database/supabase_schema.sql"
type: "code"
community: "Liquidations Table"
location: "L46-L57"
tags:
  - graphify/code
  - graphify/EXTRACTED
  - community/Liquidations_Table
---

# Liquidations Table

## Connections
- [[Cash Advance Requests Table]] - `references` [EXTRACTED]
- [[Financial Secretary Role]] - `approves` [EXTRACTED]
- [[Liquidation Files Table]] - `references` [EXTRACTED]
- [[Liquidation Flow Frontend]] - `shares_data_with` [EXTRACTED]
- [[Row Level Security]] - `protects` [EXTRACTED]
- [[Workflow Actions]] - `updates` [EXTRACTED]

#graphify/code #graphify/EXTRACTED #community/Liquidations_Table