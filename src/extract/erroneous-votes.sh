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

# Normalize correction arrays of name strings or person objects, to only objects - even if some have to be faked.
# names(n) checks for null arrays, arrays that are person objects, or just name strings which are converted into objects.
read -d '' cleanCorrectionalNameObjectArrays <<"EOF"
def cleanedMepObjectArray(n):
	if n then
		n
		| map(
			if (. | type) == "string" then
				{
					id: .,
					name: .,
					faked: true
				}
			else
				{
					id,
					name: .orig
				}
			end
		)
	else
		[]
	end;

.
| map({
	dossierid,
	title,
	ts,
	abstain: {
		total: .abstain.total,
		correctors: cleanedMepObjectArray(.abstain.correctional)
	},
	against: {
		total: .against.total,
		correctors: cleanedMepObjectArray(.against.correctional)
	},
	for: {
		total: .for.total,
		correctors: cleanedMepObjectArray(.for.correctional)
	}
})
EOF

# Group corrections by MEP database ID, or the faked ID based on MEP name.
read -d '' groupCorrectionsByMEP <<"EOF"
.
| map(
	(.abstain.correctors + .against.correctors + .for.correctors)
)
| reduce
	.[] as $item
	(
		[];
		. + $item
	)
| group_by(.id)
| map(reduce
	.[] as $item
	(
		{
			corrections: 0,
			names: {},
			faked: false
		};
		{
			id: $item.id,
			corrections: (
					.corrections + 1
				),
			names:
				(
					.names
					+
					(
						[
							{
								key: $item.name,
								value: ((.names[$item.name] // 0) + 1)
							}
						]
						| from_entries
					)
				),
			faked: (
					.faked or ($item.faked // false)
				)
		}
	)
)
| sort_by(.corrections)
EOF

<"$infile" jq "$getVotingsWithCorrectionals" > "$outdir/correctionals.unsorted.json"

<"$outdir/correctionals.unsorted.json" jq "$sortVotingsByTimestampDescending" > "$outdir/correctionals.json"

<"$outdir/correctionals.json" jq "$cleanCorrectionalNameObjectArrays" > "$outdir/correctionals.mep-objects.json"

<"$outdir/correctionals.mep-objects.json" jq "$groupCorrectionsByMEP" > "$outdir/correctionals.grouped-by-mep.json"
