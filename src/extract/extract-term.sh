#!/usr/bin/env bash
set -e
set -u

# https://en.wikipedia.org/wiki/Fifth_European_Parliament
# https://en.wikipedia.org/wiki/Sixth_European_Parliament
# https://en.wikipedia.org/wiki/Seventh_European_Parliament
# https://en.wikipedia.org/wiki/Eighth_European_Parliament
declare -a terms
#terms["5"]='null/"2004-07-20T00:00:00Z"' # The current Parltrack data doesn't contain any data from the fifth term
terms["6"]='"2004-07-20T00:00:00Z"/"2009-07-14T00:00:00Z"'
terms["7"]='"2009-07-14T00:00:00Z"/"2014-07-01T00:00:00Z"'
terms["8"]='"2014-07-01T00:00:00Z"/null'

term="$1"
shift

dates=(${terms[${term}]//\// })
start="${dates[0]}"
end="${dates[1]}"

cat - | "${BASH_SOURCE%/*}/extract-date-range.sh" "$start" "$end"
