#!/usr/bin/env bash
set -e
set -u

# Extracts MEPs active during a date range.

# The placeholders %STARTDATE% and %ENDDATE% are expected to be replaced with either
# 	- null
# 	- an ISO 8601 date/time string, in quotes: "2009-07-14T00:00:00Z".
# Current implementation uses dates instead of timestamps to void some string comparison differences.
read -d '' extractMepDateRangeTemplate <<"EOF" || true
def isNull:
	type == "null";

def isNotNull:
	isNull | not;

def rangeDate:
	if type == "null" then
		null
	elif type == "string" and length >= 10 then
		.[0:9]
	else
		null
	end;

(%STARTDATE% | rangeDate) as $rangeStartDate
| (%ENDDATE% | rangeDate) as $rangeEndDate
| select(
	(
		# According to Stef/parltrack, Constituencies should be enough.
		# https://github.com/pudo/parltrack/issues/25
		[]
		+ (.Constituencies // [])
		+ (.Committees // [])
		+ (.Delegations // [])
		+ (.Groups // [])
	)
	| map(
		# Not a valid start date? Random defensive test, haven't been confirmed.
		select(isNotNull)
		| select(.start | isNotNull)
		| (.start | rangeDate) as $startDate
		| (.end | rangeDate) as $endDate
		| (
			#  MEP started before, but ended during selected date range.
			(
				(($rangeStartDate | isNotNull) and ($startDate < $rangeStartDate))
				and (($rangeStartDate | isNotNull) and ($endDate > $rangeStartDate))
			)
			#  MEP started started and ended within the selected date range.
			# According to Stef/parltrack, this range check (on Constituencies only) should be enough to extract full terms.
			# https://github.com/pudo/parltrack/blob/master/parltrack/views/views.py#L282
			or (
				(($rangeStartDate | isNull) or ($startDate >= $rangeStartDate))
				and ((($rangeEndDate | isNull) and ($endDate | isNotNull)) or ($endDate < $rangeEndDate))
			)
			#  MEP started during selected date range, but ended after.
			or (
				(($rangeEndDate | isNotNull) and ($startDate < $rangeEndDate))
				and (($rangeEndDate | isNotNull) and ($endDate > $rangeEndDate))
			)
			#  MEP started before, and ended after selected date range.
			or (
				(($rangeStartDate | isNotNull) and ($startDate < $rangeStartDate))
				and ((($rangeEndDate | isNotNull) and ($endDate | isNotNull)) and ($endDate > $rangeEndDate))
			)
			#  MEP started before the date range ended, and has no end date.
			or (
				(($rangeEndDate | isNull) or ($startDate < $rangeEndDate))
				and (($endDate | isNull) or ($endDate | startswith("9999")))
			)
		)
	)
	| any
)
EOF

jqExtractMepDateRange() {
	local t="$extractMepDateRangeTemplate"
	t=${t/"%STARTDATE%"/$1}
	t=${t/"%ENDDATE%"/$2}
	echo "$t"
}

start="$1"
shift
end="$1"
shift

cat - | jq "$(jqExtractMepDateRange ${start} ${end})"
