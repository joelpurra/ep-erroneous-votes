#!/usr/bin/env bash
set -e
set -u

files=("aggregates.json" "ep_votes.term.info.json" "ep_votes.term.file-info.json" "aggregates.file-info.json" "aggregates.votings.json" "aggregates.with-corrections.votings.json")

"${BASH_SOURCE%/*}/../utils/merge.sh" ${files[@]} | "${BASH_SOURCE%/*}/../utils/sort-object-keys-deep.sh" > "aggregates.json"
