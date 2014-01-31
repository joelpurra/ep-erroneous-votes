#!/bin/bash
#set -e

# Split a given ep_votes.json style file and split into known European Parliament terms

# https://en.wikipedia.org/wiki/Fifth_European_Parliament
# https://en.wikipedia.org/wiki/Sixth_European_Parliament
# https://en.wikipedia.org/wiki/Seventh_European_Parliament
declare -a terms
#terms["5"]='null/"2004-07-20T00:00:00Z"' # The current Parltrack data doesn't contain any data from the fifth term
terms["6"]='"2004-07-20T00:00:00Z"/"2009-07-14T00:00:00Z"'
terms["7"]='"2009-07-14T00:00:00Z"/null'


now=$(date -u +%FT%TZ)
nowpath=$(echo "$now" | tr -d ':')
infile="${1:-"$PWD/ep_votes.json"}"
outdir="${2:-"$PWD/$nowpath"}"
mkdir -p "$outdir"

echo "Current date: $now"
echo "Input ep_votes.json file: $infile"
echo "Output directory: $outdir"

infileBasenameWithoutSuffix=$(basename "$infile" ".json")

# http://parltrack.euwiki.org/dumps/schema.html

# Template string for splitting votings into terms
# The placeholders %STARTDATE% and %ENDDATE% are expected to be replaced with either
# 	- null
# 	- an ISO 8601 date/time string, in quotes: "2009-07-14T00:00:00Z".
read -d '' extractTermTemplate <<"EOF"
%STARTDATE% as $startTS |
%ENDDATE% as $endTS |
.
| map(select(
	(
		(($startTS == null) or (.ts >= $startTS))
		and
		($endTS == null) or (.ts < $endTS))
	)
)
EOF

jqExtractTerm() {
	t="$extractTermTemplate"
	t=${t/"%STARTDATE%"/$1}
	t=${t/"%ENDDATE%"/$2}
	echo "$t"
}

for term in ${!terms[@]}; do
	dates=(${terms[${term}]//\// })
	# TODO: when there's a new release of jq, try to add the --unbuffered flag
	# http://stedolan.github.io/jq/manual/#Invokingjq
    <"$infile" jq --compact-output "$(jqExtractTerm ${dates[0]} ${dates[1]})" > "$outdir/$infileBasenameWithoutSuffix.term-$term.json"
done

