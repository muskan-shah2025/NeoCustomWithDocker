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


const fs = require('fs');
const FormData = require('form-data');
const axios = require('axios');

// Get file path from command line argument
const filePath = process.argv[2];

if (!filePath || !fs.existsSync(filePath)) {
  console.error("❌ SBOM file not found or path not provided.");
  process.exit(1);
}

// Read environment variables (with defaults)
const API_URL = process.env.API_URL || "http://64.227.149.25:8081/api/v1/bom";
const PROJECT_ID = process.env.PROJECT_ID || "33d18e5f-d030-4a9b-89ca-6374bc85efac";
const SECRET_KEY = process.env.SECRET_KEY || "odt_hB9IN3oV5zMVUzSSt0Ad1qERGwW70YX7";

// Async function to upload the file
(async () => {
  try {
    const form = new FormData();
    form.append('project', PROJECT_ID);
    form.append('bom', fs.createReadStream(filePath));

    const response = await axios.post(API_URL, form, {
      headers: {
        ...form.getHeaders(),
        'x-api-key': SECRET_KEY
      },
      maxBodyLength: Infinity // prevent size limit issues
    });

    console.log("✅ SBOM uploaded successfully:", response.status);
  } catch (err) {
    console.error("❌ Failed to upload SBOM:", err.message);
    process.exit(1);
  }
})();
