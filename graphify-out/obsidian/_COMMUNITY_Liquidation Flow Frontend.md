---
type: community
cohesion: 0.25
members: 8
---

# Liquidation Flow Frontend

**Cohesion:** 0.25 - loosely connected
**Members:** 8 nodes

## Members
- [[Audit Logs Table]] - code - database/supabase_schema.sql
- [[Cash Advance Request Creation]] - concept - public/cash_advance_supabase.html
- [[Liquidation Flow Frontend]] - document - public/cash_advance_supabase.html
- [[Profile Loading]] - concept - public/cash_advance_supabase.html
- [[Requester Portal]] - document - public/requester.html
- [[Staff Portal]] - document - public/staff.html
- [[Supabase Authentication]] - concept - public/cash_advance_supabase.html
- [[Supabase Data Loading]] - concept - public/cash_advance_supabase.html

## Live Query (requires Dataview plugin)

```dataview
TABLE source_file, type FROM #community/Liquidation_Flow_Frontend
SORT file.name ASC
```

## Connections to other communities
- 3 edges to [[_COMMUNITY_Liquidations Table]]
- 2 edges to [[_COMMUNITY_Profiles Table]]
- 1 edge to [[_COMMUNITY_Cash Advance Requests Table]]

## Top bridge nodes
- [[Liquidation Flow Frontend]] - degree 13, connects to 3 communities