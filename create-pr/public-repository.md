# Public Repository Publication

Apply every rule in this file when repository visibility is `PUBLIC`. Public Git data can remain in caches, mirrors, notification emails, and search results after branches or PRs are deleted.

## Before push

Review every branch name and commit message that will be published. Remove:

- internal URLs or issue links from private repositories
- internal IDs, project codenames, and team references
- customer names, account IDs, user IDs, or other customer data
- employee names and private process details

For an unpushed branch with sensitive content in its name, propose a sanitized rename and wait for confirmation. For sensitive commit metadata, stop and propose an amend or squash before push. These history changes require explicit user approval.

This gate is complete when every branch name and commit message is safe for public visibility.

## Before PR creation or update

Sanitize every proposed PR title and body using the same categories. Keep the text understandable to an external contributor. Show the exact titles and bodies that will be published, then print this warning:

```text
WARNING: This repository is PUBLIC. The PR title, description, comments,
commits, and full diff will be permanently visible to anyone on the internet
— even if the PR is later closed or the branch is deleted, the history remains.

Please review the PR description above and confirm you're comfortable with
everything in it being public.
```

Wait for explicit confirmation. For a stack, confirmation covers only the displayed set of branches, titles, and bodies; ask again if that set changes.

This gate is complete when the user explicitly approves the exact publication content.
