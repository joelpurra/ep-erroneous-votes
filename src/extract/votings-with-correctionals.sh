#!/usr/bin/env bash
set -e
set -u

# Select votings with at least one correction.
# Then select the relevant values, including all correction objects.
read -d '' getVotingsWithCorrectionals <<"EOF" || true
def withCorrections:
	select(
			(
				(.Abstain.correctional | length)
				+ (.Against.correctional | length)
				+ (.For.correctional | length)
			) > 0
		);

withCorrections
EOF

cat - | jq --unbuffered "$getVotingsWithCorrectionals"
