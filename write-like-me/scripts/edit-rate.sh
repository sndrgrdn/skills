#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: edit-rate.sh <draft> <final>

Rough word-level diff between a draft and the user's edited final.

A token is a word (internal apostrophes stay attached) or a single
punctuation mark.

  edit rate = (inserted + deleted) / (draft tokens + final tokens)

0 is identical. 1 means no token lined up with the final.

Prints the counts, the rate, and the token diff (d = deleted, a = inserted).
Does not classify edits. Exits 0 when the files differ.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 2 ]]; then
  usage >&2
  exit 2
fi

draft=$1
final=$2

for f in "$draft" "$final"; do
  if [[ ! -f "$f" ]]; then
    echo "error: not a file: $f" >&2
    exit 2
  fi
done

tokenize() {
  grep -oP "[\p{L}\p{N}]+(?:['’][\p{L}\p{N}]+)?|[^\p{L}\p{N}\s]" "$1" || true
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

tokenize "$draft" > "$tmp/draft"
tokenize "$final" > "$tmp/final"

draft_n=$(wc -l < "$tmp/draft" | tr -d ' ')
final_n=$(wc -l < "$tmp/final" | tr -d ' ')

diff_out=$(diff --old-line-format='d %L' --new-line-format='a %L' --unchanged-line-format='' "$tmp/draft" "$tmp/final" || true)

if [[ -z "$diff_out" ]]; then
  inserted=0
  deleted=0
else
  inserted=$(printf '%s\n' "$diff_out" | grep -c '^a ' || true)
  deleted=$(printf '%s\n' "$diff_out" | grep -c '^d ' || true)
fi

denom=$((draft_n + final_n))
if [[ "$denom" -eq 0 ]]; then
  rate="0.000"
else
  rate=$(awk -v i="$inserted" -v d="$deleted" -v n="$denom" 'BEGIN { printf "%.3f", (i + d) / n }')
fi

printf 'draft_tokens: %s\n' "$draft_n"
printf 'final_tokens: %s\n' "$final_n"
printf 'inserted: %s\n' "$inserted"
printf 'deleted: %s\n' "$deleted"
printf 'edit_rate: %s\n' "$rate"

if [[ -n "$diff_out" ]]; then
  printf '\n%s\n' "$diff_out"
fi
