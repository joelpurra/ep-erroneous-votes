#!/usr/bin/env bash
set -e
set -u

# Get aggregate data from the input file
# TODO: remove hardcoded "name" exceptions from totalAsNumber, when the upstream data has been cleaned
read -d '' getAggregates <<"EOF" || true
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
		),
		"corrected-votes": (
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
		),
		"date-range": {
			newest: (max_by(.ts) | .ts),
			oldest: (min_by(.ts) | .ts)
		}
	};

getAggregates
EOF

cat - | jq "$getAggregates"
