#!/usr/bin/env bash
set -e
set -u

# Extracts votings withing a date range.

# The placeholders %STARTDATE% and %ENDDATE% are expected to be replaced with either
# 	- null
# 	- an ISO 8601 date/time string, in quotes: "2009-07-14T00:00:00Z".
read -d '' extractDateRangeTemplate <<"EOF" || true
def isNull:
	type == "null";

%STARTDATE% as $startTS
| %ENDDATE% as $endTS
| select(
	(($startTS | isNull) or (.ts >= $startTS))
	and
	(($endTS | isNull) or (.ts < $endTS))
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
