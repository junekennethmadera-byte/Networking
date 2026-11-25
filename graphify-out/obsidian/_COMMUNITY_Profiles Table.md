---
type: community
cohesion: 0.40
members: 5
---

# Profiles Table

**Cohesion:** 0.40 - moderately connected
**Members:** 5 nodes

## Members
- [[Application Roles]] - concept - database/supabase_schema.sql
- [[Automatic Profile Provisioning]] - concept - database/supabase_schema.sql
- [[Cash Advance Documents Storage]] - concept - database/supabase_schema.sql
- [[Profiles Table]] - code - database/supabase_schema.sql
- [[Row Level Security]] - concept - database/supabase_schema.sql

## Live Query (requires Dataview plugin)

```dataview
TABLE source_file, type FROM #community/Profiles_Table
SORT file.name ASC
```

## Connections to other communities
- 2 edges to [[_COMMUNITY_Liquidation Flow Frontend]]
- 2 edges to [[_COMMUNITY_Cash Advance Requests Table]]
- 1 edge to [[_COMMUNITY_Liquidations Table]]

## Top bridge nodes
- [[Profiles Table]] - degree 5, connects to 2 communities
- [[Row Level Security]] - degree 4, connects to 2 communities
- [[Cash Advance Documents Storage]] - degree 2, connects to 1 community