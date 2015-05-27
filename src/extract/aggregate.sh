#!/usr/bin/env bash
set -e
set -u

# Get aggregate data from the input file
# TODO: remove hardcoded "name" exceptions from totalAsNumber, when the upstream data has been cleaned
read -d '' getAggregates <<"EOF" || true
def flatten:
	reduce
		.[] as $item
		(
			[];
			. + $item
		);

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

def allVoteIds:
	if . and .groups and (.groups | type) == "array" then
		[
			.groups[]
			| select((.votes | type) == "array")
			| .votes[]
			| select((.id | type) == "string")
			| .id
		]
		# They should already be unique, but what the hell.
		| unique
	else
		[]
	end;

def allCorrectionalVoteIds:
	if . and .correctional and (.correctional | type) == "array" then
		[
			.correctional[]
			| select((.id | type) == "string")
			| .id
		]
		# They should already be unique, but what the hell.
		| unique
	else
		[]
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
		"voters": (
			map(
				(.Abstain | allVoteIds)
				+ (.Against | allVoteIds)
				+ (.For | allVoteIds)
			)
			| flatten
			| unique
			| length
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
		"corrected-voters": (
			map(
				(.Abstain | allCorrectionalVoteIds)
				+ (.Against | allCorrectionalVoteIds)
				+ (.For | allCorrectionalVoteIds)
			)
			| flatten
			| unique
			| length
		),
		"date-range": {
			newest: (max_by(.ts) | .ts),
			oldest: (min_by(.ts) | .ts)
		}
	};

getAggregates
EOF

cat - | jq "$getAggregates"
