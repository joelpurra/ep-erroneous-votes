# [ep-erroneous-votes](https://github.com/joelpurra/ep-erroneous-votes)

<p class="donate">
  <a href="https://joelpurra.com/donate/proceed/?amount=5&currency=usd"><kbd>Donate $5 now</kbd></a>
  <a href="https://joelpurra.com/donate/proceed/?amount=25&currency=usd"><kbd>Donate $25 now</kbd></a>
  <a href="https://joelpurra.com/donate/proceed/?amount=100&currency=usd&invoice=true"><kbd>Donate $100 now</kbd></a>
  <a href="https://joelpurra.com/donate/"><kbd>More options</kbd></a>
</p>

See [projects related to the European Parliament](https://joelpurra.com/projects/european-parliament/) for background information, data, and results.



> ## ⚠️ This project has been archived
>
> No future updates are planned. Feel free to continue using it, but expect no support.



Using [open data dumps](http://parltrack.euwiki.org/dumps) from [Parltrack](http://parltrack.euwiki.org/) to analyze erroneous, and subsequently corrected, votes by [Members](http://www.europarl.europa.eu/meps/) of the [European Parliament](http://www.europarl.europa.eu/).

Developed during the [Europarl Hackathon](http://europarl.me/), in preparation for the [European elections 2014](http://www.elections2014.eu/).



## Requirements

1. Install [jq](https://stedolan.github.io/jq/) for the JSON processing.
1. Download a fresh [ep_votes.json.xz](http://parltrack.euwiki.org/dumps/ep_votes.json.xz) and unpack it somewhere. The unpacked `ep_votes.json` file is big (500MB+); please see [the schema](http://parltrack.euwiki.org/dumps/schema.html) for an overview.



## Usage

In both cases below, arguments default to `$PWD/ep_votes.json` and `$PWD/$ISO8601UTCDATETIME`, meaning [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) formatted [UTC](https://en.wikipedia.org/wiki/Coordinated_Universal_Time) date/time for example `./2014-01-25T18:10:10Z`.

### `erroneous-votes.sh [path/to/ep_votes.json [outdir]]`

Creates JSON dumps with erroneous votes for a given `ep_votes.json`.


### `vote-counts.sh [path/to/ep_votes.json [outdir]]`

Shows the number of votings and votes for a given `ep_votes.json`.


### Displaying results

Use [`ep-the-corrections`](https://github.com/joelpurra/ep-the-corrections) to consume the generated data.



## Todo

&#9744; Split up extraction files to several pipe-able pieces, so the entire script doesn't have to run every time. Most useful during development, as a complete run takes too long.  
&#9745; Output aggregate data, such as total and filtered number of votings/votes and corrections, number of MEPs, votes, corrections per MEP, first/last voting dates, etcetera. Use a JSON format, and then update downstream visualization.  



---



Copyright &copy; 2014, 2015, 2016, 2017, [Joel Purra](https://joelpurra.com/) All rights reserved.

When using [ep-erroneous-votes](https://github.com/joelpurra/ep-erroneous-votes), comply to the [GNU Affero General Public License 3.0 (AGPL-3.0)](https://en.wikipedia.org/wiki/Affero_General_Public_License). [Your donations are appreciated!](https://joelpurra.com/donate/)
