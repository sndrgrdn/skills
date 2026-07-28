---
name: post-inline-comment
description: Use when asked to post a comment on a specific file and line in a GitHub pull request.
---

# Post Inline Review Comment

After the user explicitly asks to publish review feedback, invoke the script once per finding:

```sh
python3 ~/.agents/skills/post-inline-comment/scripts/post_inline_comment.py \
  --pr 12345 \
  --file app/models/order.rb \
  --line 42 \
  --comment "Exact review comment"
```

For multiline feedback, pass shell-quoted text:

```sh
--comment "$(cat <<'EOF'
**HIGH** This can race.

**Fix:** Lock the row before updating.
EOF
)"
```

The repository is the current checkout. The file and line identify one right-side line in the PR diff. The script posts the comment unchanged and prints its GitHub URL. An invalid anchor fails; choose the correct line and invoke it again.

Done when every finding has its own returned comment URL.
