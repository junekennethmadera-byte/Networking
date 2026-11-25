---
source_file: "database/supabase_schema.sql"
type: "code"
community: "Cash Advance Requests Table"
location: "L18-L44"
tags:
  - graphify/code
  - graphify/EXTRACTED
  - community/Cash_Advance_Requests_Table
---

# Cash Advance Requests Table

## Connections
- [[Cash Advance Liquidation Workflow]] - `describes` [EXTRACTED]
- [[Cash Advance Reference Generation]] - `generates_for` [EXTRACTED]
- [[Liquidation Flow Frontend]] - `shares_data_with` [EXTRACTED]
- [[Liquidations Table]] - `references` [EXTRACTED]
- [[Profiles Table]] - `references` [INFERRED]
- [[Requester Role]] - `participates_in` [EXTRACTED]
- [[Row Level Security]] - `protects` [EXTRACTED]
- [[Treasurer Role]] - `disburses` [EXTRACTED]
- [[Workflow Actions]] - `updates` [EXTRACTED]

#graphify/code #graphify/EXTRACTED #community/Cash_Advance_Requests_Table