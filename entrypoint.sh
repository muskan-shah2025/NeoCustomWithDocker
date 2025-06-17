#!/bin/bash
set -e

echo "👋 Hello $INPUT_WHO_TO_GREET!"

# Run cdxgen and output to GitHub workspace
echo "📦 Generating SBOM..."
cdxgen . -o /github/workspace/sbom.json

# Optional: Fix permissions so the runner can access it
chown 1001:121 /github/workspace/sbom.json || true

# Output the SBOM content as an Action output
if [ -f /github/workspace/sbom.json ]; then
  echo "✅ SBOM generated."

  sbom_output=$(jq -c . /github/workspace/sbom.json)
  echo "sbom=$sbom_output" >> "$GITHUB_OUTPUT"

  echo "🔍 Parsing SBOM for components..."
  components_json=$(node /parse-sbom.js /github/workspace/sbom.json components 2>&1) || {
    echo "❌ Error while parsing components"
    echo "$components_json"
    exit 1
  }

  echo "🔍 Parsing SBOM for vulnerabilities..."
  vulns_json=$(node /parse-sbom.js /github/workspace/sbom.json vulns 2>&1) || {
    echo "❌ Error while parsing vulnerabilities"
    echo "$vulns_json"
    exit 1
  }

  echo "✅ Parsed Components: $components_json"
  echo "✅ Parsed Vulnerabilities: $vulns_json"

  echo "components=$components_json" >> "$GITHUB_OUTPUT"
  echo "vulnerabilities=$vulns_json" >> "$GITHUB_OUTPUT"

else
  echo "sbom={}" >> "$GITHUB_OUTPUT"
  echo "⚠️ Warning: sbom.json not found!"
fi
