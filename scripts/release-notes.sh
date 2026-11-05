#!/usr/bin/env bash
# Prints the release notes (Markdown) for a release, built from the commit subjects since the
# previous tag. Commit subjects start with a type prefix (see .githooks/commit-msg):
#   Feature:      new things she can do in the app
#   Bugfix:       something that was broken works again
#   Improvement:  existing behaviour or looks got better
#   Docs:         documentation only
#   Dev:          build, CI, tooling, tests, dev container
#   Release:      version bumps (left out of the notes)
#
# Usage: scripts/release-notes.sh [<tag>]
#   With a tag: the commits between the tag before it and that tag.
#   Without, or with a tag that doesn't exist yet: the commits since the latest tag.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# A tag that doesn't exist yet (release started by hand in the Actions tab) means HEAD.
if [ $# -gt 0 ] && git rev-parse -q --verify "refs/tags/$1" >/dev/null; then
  end=$1
  prev=$(git describe --tags --abbrev=0 --match 'v*' "$end^" 2>/dev/null || true)
else
  end=HEAD
  prev=$(git describe --tags --abbrev=0 --match 'v*' HEAD 2>/dev/null || true)
fi
range=${prev:+$prev..}$end

declare -A items
other=""
while IFS= read -r subject; do
  if [[ $subject =~ ^(Feature|Bugfix|Improvement|Docs|Dev|Release):[[:space:]]*(.+)$ ]]; then
    items[${BASH_REMATCH[1]}]+="- ${BASH_REMATCH[2]}"$'\n'
  else
    other+="- $subject"$'\n'
  fi
done < <(git log --no-merges --reverse --format=%s "$range")

section() { # <heading> <text>
  [ -n "$2" ] && printf '## %s\n\n%s\n' "$1" "$2"
  return 0
}

section "New" "${items[Feature]:-}"
section "Fixed" "${items[Bugfix]:-}"
section "Improved" "${items[Improvement]:-}"
section "Behind the scenes" "${items[Dev]:-}${items[Docs]:-}"
section "Other changes" "$other"
if [ -n "$prev" ]; then
  compare="$prev...${end/#HEAD/main}"
  # In GitHub Actions, link to the compare page; locally, just name the range.
  if [ -n "${GITHUB_REPOSITORY:-}" ]; then
    compare="[$compare](${GITHUB_SERVER_URL:-https://github.com}/$GITHUB_REPOSITORY/compare/$compare)"
  fi
  echo "All commits: $compare"
fi
