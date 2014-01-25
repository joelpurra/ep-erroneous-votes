#!/bin/bash
#set -e

now=$(date -u +%FT%TZ)
indir="${1:-"$PWD"}"
outdir="${2:-"$PWD"}/$now"
mkdir -p "$outdir"

echo "Current date: $now"
echo "Input directory: $indir"
echo "Output directory: $outdir"

# http://parltrack.euwiki.org/dumps/schema.html

read -d '' getTotalVoteCountsPerVoting <<"EOF"
.
| (
	if .Abstain then
		(
			.Abstain.total | tonumber
		)
	else
		0
	end
)
+ (
	if .Against then
		(
			.Against.total | tonumber
		)
	else
		0
	end
)
+ (
	if .For then
		(
			.For.total | tonumber
		)
	else
		0
	end
)
EOF

<"$indir/ep_votes.json" jq --online-input "$getTotalVoteCountsPerVoting" > "$outdir/votecounts.log"

trim(){
	sed -E 's/^[[:space:]]*(.*)[[:space:]]*$/\1/'
}

totalVotings=$(<"$outdir/votecounts.log" wc -l | trim)

totalVotes=$(paste -s -d + "$outdir/votecounts.log" | bc)

echo "Total votings in dataset: $totalVotings"
echo "Total votes in dataset: $totalVotes"
