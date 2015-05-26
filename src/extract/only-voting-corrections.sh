#!/usr/bin/env bash
set -e
set -u

# Extract corrections
read -d '' onlyVotingCorrections <<"EOF" || true
.abstain.correctors
+ .against.correctors
+ .for.correctors
EOF

cat - | jq --unbuffered "$onlyVotingCorrections"
