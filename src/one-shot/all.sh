#!/usr/bin/env bash
set -e
set -u

selectedTerms=(6 7 8)

termEnter(){
	local termdir="term-${term}"

	mkdir -p "$termdir"

	pushd "$termdir" >/dev/null
}

termExit(){
	popd >/dev/null
}



# Vote corrections.
# TODO: correctional data seems to be broken for term 8, so it will probably return 0 corrected votes.
for term in "${selectedTerms[@]}";
do
	termEnter

	# TODO: add more file-info, like file size (cross platform) and hopefully even $createdDate
	# https://serverfault.com/questions/342316/safe-way-to-determine-size-of-a-file-using-unix-tools
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

	termExit
done



# MEP numbers.
for term in "${selectedTerms[@]}";
do
	termEnter

	<"../ep_meps_current.json" "${BASH_SOURCE%/*}/../utils/un-array.sh" | "${BASH_SOURCE%/*}/../mep/extract-term.sh" "$term" >"ep_meps_current.term.json"

	termExit
done



# Find MEP term overlap.
for term in "${selectedTerms[@]}";
do
	termEnter

	<"ep_meps_current.term.json" jq '._id' | sort -n >"ep_meps_current.term._ids.txt"

	termExit
done



# MEP numbers compared to the votes found in the term.
for term in "${selectedTerms[@]}";
do
	termEnter

	# Find number of voters in ep_votes.[term.]json
	<"ep_votes.term.json" jq '[ ( .For, .Against, .Abstain ) | select(type == "object") | .groups[] | .votes[] | select(type == "object") | .id ] | unique' >"voters.json"
	<"voters.json" jq --slurp '[ .[] | .[] ] | unique' >"voters.unique.json"
	<"voters.unique.json" jq '.[]' >"voters.unique.txt"
	comm -1 -2 "ep_meps_current.term._ids.txt" "voters.unique.txt" >"voters.unique.verified.txt"
	comm -2 -3 "ep_meps_current.term._ids.txt" "voters.unique.txt" >"voters.unique.non-voters.txt"
	comm -1 -3 "ep_meps_current.term._ids.txt" "voters.unique.txt" >"voters.unique.unknown.txt"

	termExit
done

comm -1 -2 "term-6/ep_meps_current.term._ids.txt" "term-7/ep_meps_current.term._ids.txt" >"6-7.txt"
comm -1 -2 "term-6/ep_meps_current.term._ids.txt" "term-8/ep_meps_current.term._ids.txt" >"6-8.txt"
comm -1 -2 "term-7/ep_meps_current.term._ids.txt" "term-8/ep_meps_current.term._ids.txt" >"7-8.txt"
comm -1 -2 "6-7.txt" "7-8.txt" >"6-7-8.txt"
