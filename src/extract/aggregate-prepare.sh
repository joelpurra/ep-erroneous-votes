#!/usr/bin/env bash
set -e
set -u

echo "{}" > "aggregates.json"

# TODO: break out and re-use.
now=$(date -u +%FT%TZ)
echo "{ \"aggregates\": { \"generated-at\": \"$now\" } }" > "aggregates.file-info.json"
