#!/bin/bash
#set -e

# Extract vote counts per voting, and display number of votings and number of votes.


# TODO: use these somewhere
# Number of votings with corrections
#<correctionals.json jq '. | length'
# Number of total votes in filtered set
#<correctionals.json jq '. | reduce .[] as $item (0; . + ($item.abstain.total + $item.against.total + $item.for.total))'
# Number of corrected votes
#<correctionals.json jq '. | reduce .[] as $item (0; . + (($item.abstain.correctional | length) + ($item.against.correctional | length) + ($item.for.correctional | length)))'


now=$(date -u +%FT%TZ)
nowpath=$(echo "$now" | tr -d ':')
infile="${1:-"$PWD/ep_votes.json"}"
outdir="${2:-"$PWD/$nowpath"}"
mkdir -p "$outdir"

echo "Current date: $now"
echo "Input ep_votes.json file: $infile"
echo "Output directory: $outdir"

trim(){
	sed -E 's/^[[:space:]]*(.*)[[:space:]]*$/\1/'
}

# http://parltrack.euwiki.org/dumps/schema.html

# Get the sum of abstain, against and for vote counts.
# TODO: convert to a reduce operation
read -d '' getTotalVoteCountsPerVoting <<"EOF"
.[]
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

# TODO: convert to a reduce operation
<"$infile" jq "$getTotalVoteCountsPerVoting" > "$outdir/votecounts.log"

# TODO: convert to a reduce operation
totalVotings=$(<"$outdir/votecounts.log" wc -l | trim)

# TODO: convert to a reduce operation
totalVotes=$(paste -s -d "+" "$outdir/votecounts.log" | bc)

echo "Total votings in dataset: $totalVotings"
echo "Total votes in dataset: $totalVotes"