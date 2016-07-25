# cm-config-change-detector

Simple script to detect whether Cloudera Manager configuration has changed over time. Retrieves JSON config via API. If previous output exists will compare for changes. Most likely run from cron.

Exit codes:

* 0 for no change
* 1 for error
* 2 for change 

## Requirements

* curl
* sed -- either GNU or BSD, toggleable

## Instructions

Edit the script, set the CM host, port, user name, and password. If an email recipient is set, the results will be mailed otherwise they'll be printed to STDOUT.

