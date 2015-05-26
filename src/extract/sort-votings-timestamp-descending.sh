#!/usr/bin/env bash
set -e
set -u

# Sort an array of votings.
read -d '' sortVotingsByTimestampDescending <<"EOF" || true
sort_by(.ts)
| reverse
EOF

cat - | jq "$sortVotingsByTimestampDescending"
