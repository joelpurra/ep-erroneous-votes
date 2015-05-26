#!/usr/bin/env bash
set -e
set -u

# Normalize correction arrays of name strings or person objects, to only objects - even if some have to be faked.
# names(n) checks for null arrays, arrays that are person objects, or just name strings which are converted into objects.
read -d '' cleanCorrectionalNameObjectArrays <<"EOF" || true
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

{
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
}
EOF

cat - | jq "$cleanCorrectionalNameObjectArrays"
