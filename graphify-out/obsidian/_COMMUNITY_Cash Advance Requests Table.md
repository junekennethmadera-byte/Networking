---
type: community
cohesion: 0.40
members: 5
---

# Cash Advance Requests Table

**Cohesion:** 0.40 - moderately connected
**Members:** 5 nodes

## Members
- [[Cash Advance Liquidation Workflow]] - rationale - database/supabase_schema.sql
- [[Cash Advance Reference Generation]] - concept - database/supabase_schema.sql
- [[Cash Advance Requests Table]] - code - database/supabase_schema.sql
- [[Requester Role]] - concept - database/supabase_schema.sql
- [[Treasurer Role]] - concept - database/supabase_schema.sql

## Live Query (requires Dataview plugin)

```dataview
TABLE source_file, type FROM #community/Cash_Advance_Requests_Table
SORT file.name ASC
```

## Connections to other communities
- 2 edges to [[_COMMUNITY_Profiles Table]]
- 2 edges to [[_COMMUNITY_Liquidations Table]]
- 1 edge to [[_COMMUNITY_Liquidation Flow Frontend]]

## Top bridge nodes
- [[Cash Advance Requests Table]] - degree 9, connects to 3 communities