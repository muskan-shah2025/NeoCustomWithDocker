#!/bin/bash
set -e

echo "👋 Hello $INPUT_WHO_TO_GREET!"

# 1. Generate SBOM
echo "📦 Generating SBOM using cdxgen..."
cdxgen . -o /github/workspace/sbom.json

# Optional: Fix permissions (some GitHub runners may require this)
chown 1001:121 /github/workspace/sbom.json || true

# 2. Check if SBOM was created
if [ -f /github/workspace/sbom.json ]; then
  echo "✅ SBOM generated successfully."

  # 3. Output SBOM content for reference
  sbom_output=$(jq -c . /github/workspace/sbom.json)
  echo "sbom=$sbom_output" >> "$GITHUB_OUTPUT"

  # 4. upload components and vulnerabilities
  # echo "🔍 Parsing SBOM for components..."
  # components_json=$(node /upload-sbom.js /github/workspace/sbom.json components 2>&1) || {
  #   echo "❌ Error while parsing components"
  #   echo "$components_json"
  #   exit 1
  # }

  # echo "🔍 Parsing SBOM for vulnerabilities..."
  # vulns_json=$(node /upload-sbom.js /github/workspace/sbom.json vulns 2>&1) || {
  #   echo "❌ Error while parsing vulnerabilities"
  #   echo "$vulns_json"
  #   exit 1
  # }

  # echo "✅ Parsed Components: $components_json"
  # echo "✅ Parsed Vulnerabilities: $vulns_json"

  # echo "components=$components_json" >> "$GITHUB_OUTPUT"
  # echo "vulnerabilities=$vulns_json" >> "$GITHUB_OUTPUT"

  # 5. Upload to external API
  echo "📤 Uploading SBOM to API..."

  API_URL="http://64.227.149.25:8081/api/v1/bom"
  PROJECT_ID="${PROJECT_ID:-33d18e5f-d030-4a9b-89ca-6374bc85efac}"
  SECRET_KEY="${SECRET_KEY:-odt_hB9IN3oV5zMVUzSSt0Ad1qERGwW70YX7}"

  curl -X POST "$API_URL" \
    -H "x-api-key: $SECRET_KEY" \
    -F "project=$PROJECT_ID" \
    -F "bom=@/github/workspace/sbom.json" \
    --fail

  if [ $? -eq 0 ]; then
    echo "✅ SBOM uploaded successfully."
  else
    echo "❌ Failed to upload SBOM."
    exit 1
  fi

else
  echo "sbom={}" >> "$GITHUB_OUTPUT"
  echo "⚠️ Warning: sbom.json not found!"
  exit 1
fi
