#!/usr/bin/env bash
# Run the ai-output-humanizer skill test suite.
# Wraps tests/superset/evaluate-superset.sh with sensible defaults.
#
# Usage: ./scripts/run-tests.sh [--k N] [--only TC-NN]
#   --k N       Number of trials per test case (default: 3, recommended: 5)
#   --only TC-NN Run a single test case (e.g., TC-01)
set -euo pipefail

cd "$(dirname "$0")/.."
exec ./tests/superset/evaluate-superset.sh "$@"
