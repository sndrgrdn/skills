# Working document

Shape for the durable plan surface. Keep prose thin. Show-me visuals carry structure; tables carry decisions.

Avoid file paths and code snippets that will go stale. Exception: a short prototype excerpt that encodes a decision more precisely than prose (state machine, schema shape), trimmed to the decision-rich parts.

```markdown
# <short title>

## Outcome
<what the user should observe when done>

## Done check
<the check that establishes success>

## Constraints
<limits, out of scope, compatibility, non-negotiables>

## Seams
| Seam | Existing / new | Catches | Misses |
| --- | --- | --- | --- |
| ... | ... | ... | ... |

<show-me seam map or call tree>

## Slices
| ID | Delivers | Blocked by |
| --- | --- | --- |
| ... | ... | none / ids |

<show-me slice graph>

## Open
<only unresolved questions; strike or remove as they close>
```
