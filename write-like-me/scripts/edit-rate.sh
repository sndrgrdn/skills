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
  perl -CSD -ne 'while (/[\p{L}\p{N}]+(?:[\x{27}\x{2019}][\p{L}\p{N}]+)?|[^\p{L}\p{N}\s]/g) { print "$&\n" }' < "$1"
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

tokenize "$draft" > "$tmp/draft"
tokenize "$final" > "$tmp/final"

draft_n=$(wc -l < "$tmp/draft" | tr -d ' ')
final_n=$(wc -l < "$tmp/final" | tr -d ' ')

if diff "$tmp/draft" "$tmp/final" > "$tmp/diff"; then
  :
else
  status=$?
  if [[ "$status" -ne 1 ]]; then
    exit "$status"
  fi
fi

diff_out=$(awk '/^< / { print "d " substr($0, 3) } /^> / { print "a " substr($0, 3) }' "$tmp/diff")
inserted=$(awk '/^> / { n++ } END { print n+0 }' "$tmp/diff")
deleted=$(awk '/^< / { n++ } END { print n+0 }' "$tmp/diff")

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
