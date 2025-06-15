#!/bin/bash
set -e

echo "Hello $INPUT_WHO_TO_GREET!"

# Run cdxgen and output to GitHub workspace
cdxgen . -o /github/workspace/sbom.json

# Optional: Fix permissions so the runner can access it
chown 1001:121 /github/workspace/sbom.json || true

# Output the SBOM content as an Action output
if [ -f /github/workspace/sbom.json ]; then
  sbom_output=$(jq -c . /github/workspace/sbom.json)
  echo "sbom=$sbom_output" >> "$GITHUB_OUTPUT"
else
  echo "sbom={}" >> "$GITHUB_OUTPUT"
  echo "Warning: sbom.json not found!"
fi
