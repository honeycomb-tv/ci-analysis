# CI Analytics

We've got some flakey Rails tests! It's a bit of a pain sometimes.

To effectively do something about this we need to look at the data and
identify the problem tests, so here's some scripts for processing the test
data we save on CI. :)

## Usage

Ensure you have the Ruby programming language installed, the AWS CLI
installed, and you've set up CLI 2FA so that you can access our S3 buckets
from the CLI.

```sh
# Install the deps
bundle install

# Download data from S3
./bin/download-ci-results-data.sh

# Analyse result data
bundle exec bin/count-failures-by-test.rb
```


## Future Work

Next time we run this script we'll likely only want to only select the latest
reports. Currently this selects all reports.

This is a quick and dirty script with no tests (for shame). If this is
developed more we need to add them.
