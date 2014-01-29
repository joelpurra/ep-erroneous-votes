#!/bin/bash
#set -e

# Extract votings with corrections, normalize the names of those with correctins, and list the worst "offenders".

now=$(date -u +%FT%TZ)
nowpath=$(echo "$now" | tr -d ':')
infile="${1:-"$PWD/ep_votes.json"}"
outdir="${2:-"$PWD/$nowpath"}"
mkdir -p "$outdir"

echo "Current date: $now"
echo "Input ep_votes.json file: $infile"
echo "Output directory: $outdir"

# http://parltrack.euwiki.org/dumps/schema.html

# Select votings with at least one correction.
# Then select the relevant values, including all correction objects.
read -d '' getVotingsWithCorrectionals <<"EOF"
.
| map(select(
	(
		(
			.Abstain.correctional | length
		)
		+ (
			.Against.correctional | length
		)
		+ (
			.For.correctional | length
		)
	) > 0
))
| map({
	dossierid,
	title,
	ts,
	abstain: {
		total: .Abstain.total | tonumber,
		correctional: .Abstain.correctional
	},
	against: {
		total: .Against.total | tonumber,
		correctional: .Against.correctional
	},
	for: {
		total: .For.total | tonumber,
		correctional: .For.correctional
	}
})
EOF

# Sort an array of votings.
read -d '' sortVotingsByTimestampDescending <<"EOF"
.
| sort_by(.ts)
| reverse
EOF

<"$infile" jq "$getVotingsWithCorrectionals" > "$outdir/correctionals.unsorted.json"

<"$outdir/correctionals.unsorted.json" jq "$sortVotingsByTimestampDescending" > "$outdir/correctionals.json"

# TODO: completely rewrite worst-offenders to use IDs instead of names - names are broken because of PDF parsing problems!
#<"$outdir/correctionals.name-strings.json" jq '.[] | .abstain.names + .against.names + .for.names | .[]' | grep --invert-match '\[\]' | sort | uniq -c | sort -n > "$outdir/worst-offenders.txt"
