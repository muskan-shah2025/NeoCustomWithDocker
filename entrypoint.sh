# #!/bin/bash
# set -e

# echo "👋 Hello $INPUT_WHO_TO_GREET!"

# # Run cdxgen and output to GitHub workspace
# echo "📦 Generating SBOM..."
# cdxgen . -o /github/workspace/sbom.json

# # Optional: Fix permissions so the runner can access it
# chown 1001:121 /github/workspace/sbom.json || true

# # Output the SBOM content as an Action output
# if [ -f /github/workspace/sbom.json ]; then
#   echo "✅ SBOM generated."

#   sbom_output=$(jq -c . /github/workspace/sbom.json)
#   echo "sbom=$sbom_output" >> "$GITHUB_OUTPUT"

#   echo "🔍 Parsing SBOM for components..."
#   components_json=$(node /parse-sbom.js /github/workspace/sbom.json components 2>&1) || {
#     echo "❌ Error while parsing components"
#     echo "$components_json"
#     exit 1
#   }

#   echo "🔍 Parsing SBOM for vulnerabilities..."
#   vulns_json=$(node /parse-sbom.js /github/workspace/sbom.json vulns 2>&1) || {
#     echo "❌ Error while parsing vulnerabilities"
#     echo "$vulns_json"
#     exit 1
#   }

#   echo "✅ Parsed Components: $components_json"
#   echo "✅ Parsed Vulnerabilities: $vulns_json"

#   echo "components=$components_json" >> "$GITHUB_OUTPUT"
#   echo "vulnerabilities=$vulns_json" >> "$GITHUB_OUTPUT"

# else
#   echo "sbom={}" >> "$GITHUB_OUTPUT"
#   echo "⚠️ Warning: sbom.json not found!"
# fi


const fs = require('fs');
const https = require('https');
const { execSync } = require('child_process');

function httpsGet(url) {
  return new Promise((resolve, reject) => {
    https.get(url, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    }).on('error', err => reject(err));
  });
}

function postJSON(url, jsonData) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(jsonData);
    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length,
        'User-Agent': 'GitHub-Action-SBOM-Vuln-Checker'
      }
    };
    const req = https.request(url, options, res => {
      let responseData = '';
      res.on('data', chunk => responseData += chunk);
      res.on('end', () => resolve(responseData));
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function compareVersions(v1, v2) {
  // Basic semantic version compare, returns true if v1 < v2
  const a = v1.split('.').map(x => parseInt(x));
  const b = v2.split('.').map(x => parseInt(x));
  for(let i=0; i < Math.max(a.length, b.length); i++){
    const num1 = a[i] || 0;
    const num2 = b[i] || 0;
    if(num1 < num2) return true;
    if(num1 > num2) return false;
  }
  return false;
}

async function fetchLatestMavenVersion(groupId, artifactId) {
  const groupPath = groupId.replace(/\./g, '/');
  const url = `https://repo1.maven.org/maven2/${groupPath}/${artifactId}/maven-metadata.xml`;

  try {
    const xml = await httpsGet(url);
    // Parse <release> or <latest> from xml
    const matchRelease = xml.match(/<release>(.*?)<\/release>/);
    if (matchRelease) return matchRelease[1];

    const matchLatest = xml.match(/<latest>(.*?)<\/latest>/);
    if (matchLatest) return matchLatest[1];

    return null;
  } catch (err) {
    // Could not get version info
    return null;
  }
}

async function queryOSSIndex(groupId, artifactId, version) {
  const coordinates = [`pkg:maven/${groupId}/${artifactId}@${version}`];
  const url = 'https://ossindex.sonatype.org/api/v3/component-report';

  try {
    const resp = await postJSON(url, { coordinates });
    const json = JSON.parse(resp);
    if (json.length && json[0].vulnerabilities) {
      return json[0].vulnerabilities.map(vuln => ({
        id: vuln.id || '',
        title: vuln.title || '',
        description: vuln.description || '',
        cvssScore: vuln.cvssScore || 0,
        severity: vuln.cvssScore >= 7 ? 'high' : (vuln.cvssScore >= 4 ? 'medium' : 'low'),
        reference: vuln.reference || ''
      }));
    }
    return [];
  } catch (err) {
    console.error('Error querying OSS Index:', err.message);
    return [];
  }
}

(async () => {
  const filePath = process.argv[2];
  if (!filePath) {
    console.error('No SBOM file path provided');
    process.exit(1);
  }

  try {
    const raw = fs.readFileSync(filePath, 'utf-8');
    const sbom = JSON.parse(raw);

    const components = (sbom.components || []).map(c => ({
      group: c.group || c.groupId || '',
      name: c.name || c.artifactId || '',
      version: c.version || '',
    }));

    let results = [];

    for (const comp of components) {
      // Skip if no required fields
      if (!comp.group || !comp.name || !comp.version) continue;

      const latestVersion = await fetchLatestMavenVersion(comp.group, comp.name);
      const vulns = await queryOSSIndex(comp.group, comp.name, comp.version);

      // Determine severity
      let severity = 'low';
      if (vulns.length > 0) {
        severity = 'high';
      } else if (latestVersion && compareVersions(comp.version, latestVersion)) {
        severity = 'medium'; // outdated
      }

      results.push({
        component: comp,
        latestVersion,
        severity,
        vulnerabilities: vulns,
      });
    }

    console.log(JSON.stringify(results));
  } catch (err) {
    console.error('Error processing SBOM:', err.message);
    process.exit(1);
  }
})();

