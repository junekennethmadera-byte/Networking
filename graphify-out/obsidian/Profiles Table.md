---
source_file: "database/supabase_schema.sql"
type: "code"
community: "Profiles Table"
location: "L6-L16"
tags:
  - graphify/code
  - graphify/EXTRACTED
  - community/Profiles_Table
---

# Profiles Table

## Connections
- [[Application Roles]] - `implements` [EXTRACTED]
- [[Automatic Profile Provisioning]] - `provisions` [EXTRACTED]
- [[Cash Advance Requests Table]] - `references` [INFERRED]
- [[Liquidation Flow Frontend]] - `shares_data_with` [EXTRACTED]
- [[Row Level Security]] - `protects` [EXTRACTED]

#graphify/code #graphify/EXTRACTED #community/Profiles_Table