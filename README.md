# [ep-erroneous-votes](https://github.com/joelpurra/ep-erroneous-votes)

Using [open data dumps](http://parltrack.euwiki.org/dumps) from [Parltrack](http://parltrack.euwiki.org/) to analyze erroneous, and subsequently corrected, votes by [Members](http://www.europarl.europa.eu/meps/) of the [European Parliament](http://www.europarl.europa.eu/).

Developed during the [Europarl Hackathon](http://europarl.me/), in preparation for the [European elections 2014](http://www.elections2014.eu/).



## Usage

1. Install [jq](http://stedolan.github.io/jq/) for the JSON processing.
1. Download a fresh [ep_votes.json.xz](http://parltrack.euwiki.org/dumps/ep_votes.json.xz) and unpack it somewhere. The unpacked `ep_votes.json` file is big (500MB+); please see [the schema](http://parltrack.euwiki.org/dumps/schema.html) for an overview.
1. Run the scripts.
  - `erroneous-votes.sh [indir [outdir]]` creates JSON dumps with erroneous votes for a given `ep_votes.json`.
  - `vote-counts.sh [indir [outdir]]` shows the number of votings and votes for a given `ep_votes.json`.


## Todo

- Create a web page to consume and display the results - but in a separate repository.



## License

Copyright (c) 2014, [Joel Purra](http://joelpurra.com/) All rights reserved.

When using ep-erroneous-votes, comply to the [GNU Affero General Public License 3.0 (AGPL-3.0)](https://en.wikipedia.org/wiki/Affero_General_Public_License). Please see the LICENSE file for details.
