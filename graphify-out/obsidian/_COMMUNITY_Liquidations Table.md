---
type: community
cohesion: 0.50
members: 4
---

# Liquidations Table

**Cohesion:** 0.50 - moderately connected
**Members:** 4 nodes

## Members
- [[Financial Secretary Role]] - concept - database/supabase_schema.sql
- [[Liquidation Files Table]] - code - database/supabase_schema.sql
- [[Liquidations Table]] - code - database/supabase_schema.sql
- [[Workflow Actions]] - concept - public/cash_advance_supabase.html

## Live Query (requires Dataview plugin)

```dataview
TABLE source_file, type FROM #community/Liquidations_Table
SORT file.name ASC
```

## Connections to other communities
- 3 edges to [[_COMMUNITY_Liquidation Flow Frontend]]
- 2 edges to [[_COMMUNITY_Cash Advance Requests Table]]
- 1 edge to [[_COMMUNITY_Profiles Table]]

## Top bridge nodes
- [[Liquidations Table]] - degree 6, connects to 3 communities
- [[Workflow Actions]] - degree 3, connects to 2 communities
- [[Liquidation Files Table]] - degree 2, connects to 1 community