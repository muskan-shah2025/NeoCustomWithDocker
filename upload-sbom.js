const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const FormData = require('form-data');

// Configs from env
const projectId = process.env.PROJECT_ID || '33d18e5f-d030-4a9b-89ca-6374bc85efac';
const secretKey = process.env.SECRET_KEY || 'odt_hB9IN3oV5zMVUzSSt0Ad1qERGwW70YX7';
const apiUrl = 'http://64.227.149.25:8081/api/v1/bom';
const sbomPath = path.resolve('/github/workspace/sbom.json');

console.log(`👋 Hello ${process.env.INPUT_WHO_TO_GREET || 'Developer'}!`);

try {
  console.log('📦 Generating SBOM using cdxgen...');
  execSync(`cdxgen . -o ${sbomPath}`, { stdio: 'inherit' });

  if (!fs.existsSync(sbomPath)) {
    console.error('❌ SBOM generation failed: sbom.json not found!');
    process.exit(1);
  }

  console.log('✅ SBOM generated.');

  console.log('📤 Uploading SBOM to API...');

  const form = new FormData();
  form.append('project', projectId);
  form.append('bom', fs.createReadStream(sbomPath));

  axios.post(apiUrl, form, {
    headers: {
      ...form.getHeaders(),
      'x-api-key': secretKey
    }
  })
  .then(() => {
    console.log('✅ SBOM uploaded successfully.');
  })
  .catch((err) => {
    console.error('❌ Failed to upload SBOM:', err.response?.data || err.message);
    process.exit(1);
  });

} catch (err) {
  console.error('❌ Error during SBOM processing:', err.message);
  process.exit(1);
}
