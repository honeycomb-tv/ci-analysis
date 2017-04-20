# CI Analytics

We've got some flakey Rails tests! It's a bit of a pain sometimes.

To effectively do something about this we need to look at the data and
identify the problem tests, so here's some scripts for processing the test
data we save on CI. :)

## Usage

```sh
# Download data from S3
./bin/download-ci-results-data.sh

# Analyse result data
bundle exec bin/count-failures-by-test.rb
```
