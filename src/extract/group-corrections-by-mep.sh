#!/usr/bin/env bash
set -e
set -u

# Group corrections by MEP database ID, or the faked ID based on MEP name.
read -d '' groupCorrectionsByMEP <<"EOF" || true
def flatten:
	reduce
		.[] as $item
		(
			[];
			. + $item
		);

def keyCounterObject(key):
	key as $key
	| .
	+
	(
		[
			{
				key: $key,
				value: ((.[$key] // 0) + 1)
			}
		]
		| from_entries
	);

flatten
| group_by(.id)
| map(reduce
	.[] as $item
	(
		{
			corrections: 0,
			names: {},
			faked: false
		};
		{
			id: $item.id,
			corrections: (
					.corrections + 1
				),
			names: .names | keyCounterObject($item.name),
			faked: (
					.faked or ($item.faked // false)
				)
		}
	)
)
| sort_by(.corrections)
EOF

cat - | jq --unbuffered "$groupCorrectionsByMEP"
