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

   # Run JavaScript parser to extract components and vulnerabilities
  echo "🔍 Parsing SBOM for components and vulnerabilities..."
  components_json=$(node /parse-sbom.js /github/workspace/sbom.json components)
  vulns_json=$(node /parse-sbom.js /github/workspace/sbom.json vulns)

  # Output parsed data (optional: remove if not needed)
  echo "components=$components_json" >> "$GITHUB_OUTPUT"
  echo "vulnerabilities=$vulns_json" >> "$GITHUB_OUTPUT"
  
else
  echo "sbom={}" >> "$GITHUB_OUTPUT"
  echo "Warning: sbom.json not found!"
fi
