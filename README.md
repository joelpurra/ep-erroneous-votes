# [ep-erroneous-votes](https://github.com/joelpurra/ep-erroneous-votes)

Using [open data dumps](http://parltrack.euwiki.org/dumps) from [Parltrack](http://parltrack.euwiki.org/) to analyze erroneous, and subsequently corrected, votes by Members of the European Parliaments.



## Usage

1. Download [ep_votes.json.xz](http://parltrack.euwiki.org/dumps/ep_votes.json.xz) and unpack it somewhere. The unpacked `ep_votes.json` file is big (500MB+); please see [the schema](http://parltrack.euwiki.org/dumps/schema.html) for an overview.
1. Run the scripts.
  - `extract-and-prepare.sh [indir [outdir]]` creates JSON dumps with erroneous votes.
  - `vote-counts.sh [indir [outdir]]` creates lists of number of votes.


## Todo

- Write a TODO list.



## License

Copyright (c) 2014, [Joel Purra](http://joelpurra.com/) All rights reserved.

When using ep-erroneous-votes, comply to the [GNU Affero General Public License 3.0 (AGPL-3.0)](https://en.wikipedia.org/wiki/Affero_General_Public_License). Please see the LICENSE file for details.
