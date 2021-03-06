#!/usr/bin/env bash
set -e
set -u

<"ep_votes.term.json" "${BASH_SOURCE%/*}/../extract/votings-with-correctionals.sh" >"ep_votes.term.votings-with-correctionals.json"

<"ep_votes.term.votings-with-correctionals.json" "${BASH_SOURCE%/*}/../extract/voting-corrections.sh" >"ep_votes.term.votings-with-correctionals.mapped.json"

<"ep_votes.term.votings-with-correctionals.mapped.json" "${BASH_SOURCE%/*}/../utils/to-array.sh" | "${BASH_SOURCE%/*}/../extract/sort-votings-timestamp-descending.sh" >"ep_votes.term.votings-with-correctionals.mapped.sorted.json"

# Multi-file version
# <"ep_votes.term.votings-with-correctionals.mapped.json" "${BASH_SOURCE%/*}/../extract/clean-correctional-name-object-arrays.sh" >"ep_votes.term.votings-with-correctionals.mapped.mep-objects.json"
# <"ep_votes.term.votings-with-correctionals.mapped.mep-objects.json" "${BASH_SOURCE%/*}/../extract/only-voting-corrections.sh" >"ep_votes.term.votings-with-correctionals.mapped.mep-objects.corrections.json"
# <"ep_votes.term.votings-with-correctionals.mapped.mep-objects.corrections.json" "${BASH_SOURCE%/*}/../utils/to-array.sh" | "${BASH_SOURCE%/*}/../extract/group-corrections-by-mep.sh" >"ep_votes.term.votings-with-correctionals.mapped.mep-objects.corrections.grouped-by-mep.json"

# Single file version
<"ep_votes.term.votings-with-correctionals.mapped.json" "${BASH_SOURCE%/*}/../extract/clean-correctional-name-object-arrays.sh" | "${BASH_SOURCE%/*}/../extract/only-voting-corrections.sh" | "${BASH_SOURCE%/*}/../utils/to-array.sh" | "${BASH_SOURCE%/*}/../extract/group-corrections-by-mep.sh" >"ep_votes.term.votings-with-correctionals.mapped.mep-objects.corrections.grouped-by-mep.json"
