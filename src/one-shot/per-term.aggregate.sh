#!/usr/bin/env bash
set -e
set -u

"${BASH_SOURCE%/*}/../extract/aggregate-prepare.sh"

<"ep_votes.term.json" "${BASH_SOURCE%/*}/../utils/to-array.sh" | "${BASH_SOURCE%/*}/../extract/aggregate.sh" | "${BASH_SOURCE%/*}/../utils/as-object.sh" "complete-dataset" > "aggregates.votings.json"

<"ep_votes.term.votings-with-correctionals.json" "${BASH_SOURCE%/*}/../utils/to-array.sh" | "${BASH_SOURCE%/*}/../extract/aggregate.sh" | "${BASH_SOURCE%/*}/../utils/as-object.sh" "with-corrections" > "aggregates.with-corrections.votings.json"

"${BASH_SOURCE%/*}/../extract/aggregate-merge.sh"
