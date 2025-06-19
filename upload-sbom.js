const { spawn } = require('child_process');
const child = spawn('cdxgen', ['.','-o /github/workspace/sbom.json']);
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const FormData = require('form-data');

const projectId = process.env.PROJECT_ID;
const secretKey = process.env.SECRET_KEY;
const apiUrl = 'http://64.227.149.25:8081/api/v1/bom';

// const sbomPath = path.resolve('/github/workspace/sbom.json');

async function uploadSBOM() {
  child.stdout.on('data', (data) => {
  console.log(`Stdout: ${data}`);
});
  try {
    if (!fs.existsSync(sbomPath)) {
      console.error(`❌ SBOM file not found at ${sbomPath}`);
      process.exit(1);
    }

    const form = new FormData();
    form.append('project', projectId);
    form.append('bom', fs.createReadStream(sbomPath));

    console.log('📤 Uploading SBOM to API...');

    const response = await axios.post(apiUrl, form, {
      headers: {
        ...form.getHeaders(),
        'x-api-key': secretKey,
      },
    });

    console.log('✅ SBOM uploaded successfully:', response.data);
  } catch (err) {
    console.error('❌ Failed to upload SBOM:', err.response?.data || err.message);
    process.exit(1);
  }
}

uploadSBOM();



// const fs = require('fs');
// const path = require('path');
// const axios = require('axios');
// const FormData = require('form-data');

// // Configs from env or defaults
// const projectId = process.env.PROJECT_ID || '33d18e5f-d030-4a9b-89ca-6374bc85efac';
// const secretKey = process.env.SECRET_KEY || 'odt_hB9IN3oV5zMVUzSSt0Ad1qERGwW70YX7';
// const apiUrl = 'http://64.227.149.25:8081/api/v1/bom';

// // The SBOM file location inside the container
// const sbomPath = path.resolve('/github/workspace/sbom.json');

// async function uploadSBOM() {
//   try {
//     if (!fs.existsSync(sbomPath)) {
//       console.error(`❌ SBOM file not found at ${sbomPath}`);
//       process.exit(1);
//     }

//     const form = new FormData();
//     form.append('project', projectId);
//     form.append('bom', fs.createReadStream(sbomPath));

//     console.log('📤 Uploading SBOM to API...');

//     const response = await axios.post(apiUrl, form, {
//       headers: {
//         ...form.getHeaders(),
//         'x-api-key': secretKey,
//       },
//       maxBodyLength: Infinity,
//       maxContentLength: Infinity,
//     });

//     console.log('✅ SBOM uploaded successfully:', response.data);
//   } catch (err) {
//     console.error('❌ Failed to upload SBOM:', err.response?.data || err.message);
//     process.exit(1);
//   }
// }

// uploadSBOM();
