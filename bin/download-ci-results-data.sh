#!/usr/bin/env bash
set -euo pipefail

mkdir -p data/platform
aws s3 sync --region eu-west-2  s3://hc-dev-ci-test-results/platform data/platform
