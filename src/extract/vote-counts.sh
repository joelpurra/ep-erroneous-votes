#!/bin/bash
#set -e

# Extract vote counts per voting, and display number of votings and number of votes.

now=$(date -u +%FT%TZ)
indir="${1:-"$PWD"}"
outdir="${2:-"$PWD"}/$now"
mkdir -p "$outdir"

echo "Current date: $now"
echo "Input directory: $indir"
echo "Output directory: $outdir"

trim(){
	sed -E 's/^[[:space:]]*(.*)[[:space:]]*$/\1/'
}

# http://parltrack.euwiki.org/dumps/schema.html

# Get the sum of abstain, against and for vote counts.
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

totalVotings=$(<"$outdir/votecounts.log" wc -l | trim)

totalVotes=$(paste -s -d + "$outdir/votecounts.log" | bc)

echo "Total votings in dataset: $totalVotings"
echo "Total votes in dataset: $totalVotes"
