#!/usr/bin/env bash
set -euo pipefail

echo "Staging deploy: no deployment pipeline configured for this project."
echo "Branch: ${BRANCH:-$(git branch --show-current)}"
