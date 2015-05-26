#!/usr/bin/env bash
set -e
set -u

for term in 6 7 8;
do
	termdir="term-${term}"

	mkdir -p "$termdir"

	pushd "$termdir" >/dev/null

	<"../ep_votes.json" "${BASH_SOURCE%/*}/../utils/un-array.sh" | "${BASH_SOURCE%/*}/../extract/extract-term.sh" "$term" >"ep_votes.term.json"

	"${BASH_SOURCE%/*}/per-term.data.sh"

	popd >/dev/null
done
