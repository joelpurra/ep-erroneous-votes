#!/usr/bin/env bash
set -e
set -u

source "${BASH_SOURCE%/*}/../terms.sh"

term="$1"
shift

dates=(${terms[${term}]//\// })
start="${dates[0]}"
end="${dates[1]}"

cat - | "${BASH_SOURCE%/*}/extract-date-range.sh" "$start" "$end"
