#!/usr/bin/env bash
set -euo pipefail

script=$(cd "$(dirname "$0")" && pwd)/edit-rate.sh
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

check() {
  printf '%s' "$1" > "$tmp/draft"
  printf '%s' "$2" > "$tmp/final"
  output=$(bash "$script" "$tmp/draft" "$tmp/final")
  expected=$(printf 'draft_tokens: %s\nfinal_tokens: %s\ninserted: %s\ndeleted: %s\nedit_rate: %s' "$3" "$4" "$5" "$6" "$7")
  [[ "$output" == "$expected" || "$output" == "$expected"$'\n\n'* ]] || {
    printf 'Expected:\n%s\nGot:\n%s\n' "$expected" "$output" >&2
    exit 1
  }
}

check 'We shipped it.' 'I disagree completely!' 4 4 4 4 1.000
check 'Same text.' 'Same text.' 3 3 0 0 0.000
check 'We shipped it.' 'We fixed it.' 4 4 1 1 0.250
check 'Yes.' 'Yes!' 2 2 1 1 0.500
check '' '' 0 0 0 0 0.000
check '' 'Hello!' 0 2 2 0 1.000
check 'Hello!' '' 2 0 0 2 1.000
check "één isn't ’t café" "één isn't ’t café" 5 5 0 0 0.000
check 'don’t stop' 'don’t stop!' 2 3 1 0 0.200
check '+' '-' 1 1 1 1 1.000
[[ "$output" == *$'d +'* && "$output" == *$'a -'* ]]

if bash "$script" > "$tmp/out" 2> "$tmp/err"; then exit 1; else [[ $? == 2 ]]; fi
if bash "$script" "$tmp/missing" "$tmp/final" > "$tmp/out" 2> "$tmp/err"; then exit 1; else [[ $? == 2 ]]; fi
[[ ! -s "$tmp/out" ]]

mkdir "$tmp/bin"
for tool in perl diff; do
  printf '#!/bin/sh\nexit 2\n' > "$tmp/bin/$tool"
  chmod +x "$tmp/bin/$tool"
  if PATH="$tmp/bin:$PATH" bash "$script" "$tmp/draft" "$tmp/final" > "$tmp/out" 2> "$tmp/err"; then
    printf '%s failure was swallowed\n' "$tool" >&2
    exit 1
  fi
  [[ ! -s "$tmp/out" ]]
  rm "$tmp/bin/$tool"
done

printf 'All edit-rate tests passed.\n'
