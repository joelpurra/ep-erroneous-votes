#!/usr/bin/env bash
set -e
set -u

for term in 6 7 8;
do
	termdir="term-${term}"

	mkdir -p "$termdir"

	pushd "$termdir" >/dev/null

	# TODO: add more file-info, like file size (cross platform) and hopefully even $createdDate
	# http://serverfault.com/questions/342316/safe-way-to-determine-size-of-a-file-using-unix-tools
	# Mac OSX (BSD?): stat -f %z "$infile"
	# Linux (GNU?): stat -c %s "$infile"
	# Maybe cksum?
	# cksum "$infile" | cut -d ' ' -f 2
	# Maybe wc?
	# wc "$infile" | awk '{print $3}'
	# TODO: break out and re-use.
	now=$(date -u +%FT%TZ)
	echo "{ \"ep_votes.term\": { \"generated-at\": \"$now\" } }" > "ep_votes.term.file-info.json"

	echo "{ \"term\": ${term} }" > "ep_votes.term.info.json"

	<"../ep_votes.json" "${BASH_SOURCE%/*}/../utils/un-array.sh" | "${BASH_SOURCE%/*}/../extract/extract-term.sh" "$term" >"ep_votes.term.json"

	"${BASH_SOURCE%/*}/per-term.data.sh"

	"${BASH_SOURCE%/*}/per-term.aggregate.sh"

	popd >/dev/null
done
