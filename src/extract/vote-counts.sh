#!/bin/bash
#set -e

# Extract vote counts per voting, and display number of votings and number of votes.

now=$(date -u +%FT%TZ)
nowpath=$(echo "$now" | tr -d ':')
infile="${1:-"$PWD/ep_votes.json"}"
outdir="${2:-"$PWD/$nowpath"}"
mkdir -p "$outdir"

echo "Current date: $now"
echo "Input ep_votes.json file: $infile"
echo "Output directory: $outdir"

infileBasename=$(basename "$infile")

jqMerge() {
	jq --slurp add "$@"
}

jqDisplay() {
	# Depending of version of jq, the display output will be either
	#	- in input-order
	#	- in reverse input order
	#	- I have no idea
	jq '.'
}

# TODO: see if sortObjectKeysRecursively can be replaced by jq command line flag --sort-keys when a newer version of jq is released?
# http://stedolan.github.io/jq/manual/#Invokingjq
# https://github.com/stedolan/jq/issues/169
jqSortObjectKeysRecursively() {
	jq "$sortObjectKeysRecursively"
}

# http://parltrack.euwiki.org/dumps/schema.html

# Sort the keys in an object by key name, recursively
read -d '' sortObjectKeysRecursively <<"EOF"
def sortObjectKeysRecursively:
	if (. | type) == "object" then
		to_entries
		| sort_by(.key)
		| map({
			key,
			value: .value | sortObjectKeysRecursively
		})
		| reverse
		| from_entries
	else
		.
	end;

.
| sortObjectKeysRecursively
EOF

# Get aggregate data from the input file
# TODO: break out some functions as a library?
# TODO: remove hardcoded "name" exceptions from totalAsNumber, when the upstream data has been cleaned
read -d '' getAggregates <<"EOF"
def totalAsNumber:
	if (. == "OPRAVY HLASOVÁNÍ") or (. == "ПОПРАВКИ В ПОДАДЕНИТЕ ГЛАСОВЕ И НАМЕРЕНИЯ ЗА ГЛАСУВАНЕ") then
		0
	else
		if (. | type) == "null" then
			0
		else
			(. | tonumber)
		end
	end;

def getAggregates:
	{
		"votings": length,
		"date-range": {
			newest: (max_by(.ts) | .ts),
			oldest: (min_by(.ts) | .ts)
		}
	};

.
| {
	"complete-dataset": (
		getAggregates
		+ {
			"votes": (
				reduce .[] as $item
				(
					0;
					.
					+ (
						($item.Abstain.total | totalAsNumber)
						+ ($item.Against.total | totalAsNumber)
						+ ($item.For.total | totalAsNumber)
					)
				)
			)
		}),
	"with-corrections": (
		map(select(
					(
						(.Abstain.correctional | length)
						+ (.Against.correctional | length)
						+ (.For.correctional | length)
					) > 0
				))
		| getAggregates
		+ {
			"votes": (
				reduce .[] as $item
				(
					0;
					.
					+ (
						($item.Abstain.correctional | length)
						+ ($item.Against.correctional | length)
						+ ($item.For.correctional | length)
					)
				)
			)
		}
	)
}
EOF

echo "{}" > "$outdir/aggregates.json"

# TODO: add more file-info, like file size (cross platform) and hopefully even $createdDate
# http://serverfault.com/questions/342316/safe-way-to-determine-size-of-a-file-using-unix-tools
# Mac OSX (BSD?): stat -f %z "$infile"
# Linux (GNU?): stat -c %s "$infile"
# Maybe cksum?
# cksum "$infile" | cut -d ' ' -f 2
# Maybe wc?
# wc "$infile" | awk '{print $3}'
echo "{\"filename\": \"$infileBasename\"}" > "$outdir/aggregates.file-info.json"

<"$infile" jq "$getAggregates" > "$outdir/aggregates.votings.json"

jqMerge "$outdir/aggregates.json" "$outdir/aggregates.file-info.json" "$outdir/aggregates.votings.json" | jqSortObjectKeysRecursively > "$outdir/aggregates.json"

# TODO: don't display output from this script; split script(s) to separate extracting and displaying?
<"$outdir/aggregates.json" jqDisplay