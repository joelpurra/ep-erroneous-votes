#!/usr/bin/env bash
set -e
set -u

# Template string for splitting votings into terms
# The placeholders %STARTDATE% and %ENDDATE% are expected to be replaced with either
# 	- null
# 	- an ISO 8601 date/time string, in quotes: "2009-07-14T00:00:00Z".
read -d '' extractDateRangeTemplate <<"EOF" || true
%STARTDATE% as $startTS
| %ENDDATE% as $endTS
| select(
	(($startTS == null) or (.ts >= $startTS))
	and
	(($endTS == null) or (.ts < $endTS))
)
EOF

jqExtractDateRange() {
	local t="$extractDateRangeTemplate"
	t=${t/"%STARTDATE%"/$1}
	t=${t/"%ENDDATE%"/$2}
	echo "$t"
}

start="$1"
shift
end="$1"
shift

cat - | jq "$(jqExtractDateRange ${start} ${end})"
