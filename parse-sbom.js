const fs = require('fs');

const filePath = process.argv[2];
const mode = process.argv[3]; // "components" or "vulns"

try {
  const raw = fs.readFileSync(filePath, 'utf-8');
  const sbom = JSON.parse(raw);

  if (mode === 'components') {
    const components = (sbom.components || []).map(c => ({
      name: c.name,
      version: c.version
    }));
    console.log(JSON.stringify(components));
  } else if (mode === 'vulns') {
    const vulns = (sbom.vulnerabilities || []).map(v => ({
      id: v.id || '',
      description: v.description || '',
      source: v.source?.name || '',
      severity: v.ratings?.[0]?.severity || 'unknown'
    }));
    console.log(JSON.stringify(vulns));
  } else {
    // Default: just log summary info
    console.log(`🧩 ${sbom.components?.length || 0} components`);
    console.log(`⚠️ ${sbom.vulnerabilities?.length || 0} vulnerabilities`);
  }
} catch (err) {
  console.error('❌ Error reading/parsing SBOM:', err.message);
  process.exit(1);
}
