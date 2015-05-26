#!/usr/bin/env bash
set -e
set -u

# Select votings with at least one correction.
# Then select the relevant values, including all correction objects.
read -d '' getVotingsCorrections <<"EOF" || true
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
EOF

cat - | jq --unbuffered "$getVotingsCorrections"
