#!/bin/bash
#set -e

now=$(date -u +%FT%TZ)
indir="${1:-"$PWD"}"
outdir="${2:-"$PWD/$now"}"
mkdir -p "$outdir"

echo "Current date: $now"
echo "Input directory: $indir"
echo "Output directory: $outdir"

# http://parltrack.euwiki.org/dumps/schema.html

read -d '' getVotingsWithCorrectionals <<"EOF"
.
| select(
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
)
| [
	{
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
	}
]
EOF

read -d '' cleanCorrectionalNameObjectArrays <<"EOF"
def names(n):
	[
		(
			if n then
				(
					n[].orig // n[] // empty
				)
			else
				empty
				end
		)
	];

.[]
| [
	{
		dossierid,
		title,
		ts,
		abstain: {
			total: .abstain.total,
			names: names(.abstain.correctional)
		},
		against: {
			total: .against.total,
			names: names(.against.correctional)
		},
		for: {
			total: .for.total,
			names: names(.for.correctional)
		}
	}
]
EOF

<"$indir/ep_votes.json" jq --online-input "$getVotingsWithCorrectionals" > "$outdir/correctionals.json"

<"$indir/correctionals.json" jq "$cleanCorrectionalNameObjectArrays" > "$outdir/correctionals.name-strings.json"
