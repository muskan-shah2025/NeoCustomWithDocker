const { spawn } = require('child_process');
const fs = require('fs').promises; // Use promises for async/await
const path = require('path');
const axios = require('axios');
const FormData = require('form-data');

const projectId = process.env.PROJECT_ID;
const secretKey = process.env.SECRET_KEY;
const apiUrl = 'http://64.227.149.25:8081/api/v1/bom';
const sbomPath = path.resolve('/github/workspace/sbom-new.json');
const projectPath = process.env["GITHUB_WORKSPACE"];
async function uploadSBOM() {
  // Validate environment variables
  if (!projectId || !secretKey) {
    console.error('❌ PROJECT_ID or SECRET_KEY environment variables are missing.');
    process.exit(1);
  }

  // Run cdxgen command
  // const child = spawn('cdxgen', ['.', '-o', '/github/workspace/sbom-new.json']);
   const child = spawn('cdxgen', [projectPath, '-o', '/github/workspace/sbom-new.json']);
  // Handle child process output and errors
  child.stdout.on('data', (data) => {
    console.log(`Stdout: ${data}`);
  });

  child.stderr.on('data', (data) => {
    console.error(`Stderr: ${data}`);
  });

  // Wait for child process to complete
  await new Promise((resolve, reject) => {
    child.on('exit', (code) => {
      if (code === 0) {
        console.log('✅ cdxgen completed successfully.');
        resolve();
      } else {
        reject(new Error(`cdxgen failed with exit code ${code}`));
      }
    });
  });

  try {
    // Check if SBOM file exists
    await fs.access(sbomPath);
    console.log(`✅ SBOM file found at ${sbomPath}`);

    // Read file (optional, for logging purposes)
    const sbomContent = await fs.readFile(sbomPath, 'utf8');
    console.log('SBOM content:', sbomContent);

    // Prepare form data for API upload
    const form = new FormData();
    form.append('project', projectId);
    form.append('bom', fs.createReadStream(sbomPath));

    console.log('📤 Uploading SBOM to API...');

    // Upload to API
    const response = await axios.post(apiUrl, form, {
      headers: {
        ...form.getHeaders(),
        'x-api-key': secretKey,
      },
    });

    console.log('✅ SBOM uploaded successfully:', response.data);
    process.exit(0); // Success
  } catch (err) {
    console.error('❌ Failed to process or upload SBOM:', err.message);
    process.exit(1); // Failure
  }
}

uploadSBOM().catch((err) => {
  console.error('❌ Unexpected error:', err.message);
  process.exit(1);
});






// MY PREVIOUS CODE

// const { spawn } = require('child_process');
// // const child = spawn('cdxgen', ['.','-o /github/workspace/sbom-new.json']);
// const child = spawn('cdxgen');
// const fs = require('fs');
// const path = require('path');
// const axios = require('axios');
// const FormData = require('form-data');

// const projectId = process.env.PROJECT_ID;
// const secretKey = process.env.SECRET_KEY;
// const apiUrl = 'http://64.227.149.25:8081/api/v1/bom';

// // const sbomPath = path.resolve('/github/workspace/sbom-new.json');

// async function uploadSBOM() {
//   child.stdout.on('data', (data) => {
//   console.log(`Stdout: ${data}`);

//   fs.readFile('/github/workspace/sbom-new.json', 'utf8', (err, data) => {
//   if (err) {
//     console.error('Error reading file:', err);
//     return;
//   }
//   console.log(data);
// });
// });
  
//   // try {
//   //   if (!fs.existsSync(sbomPath)) {
//   //     console.error(`❌ SBOM file not found at ${sbomPath}`);
//   //     process.exit(1);
//   //   }

//   //   const form = new FormData();
//   //   form.append('project', projectId);
//   //   form.append('bom', fs.createReadStream(sbomPath));

//   //   console.log('📤 Uploading SBOM to API...');

//   //   const response = await axios.post(apiUrl, form, {
//   //     headers: {
//   //       ...form.getHeaders(),
//   //       'x-api-key': secretKey,
//   //     },
//   //   });

//   //   console.log('✅ SBOM uploaded successfully:', response.data);
//   // } catch (err) {
//   //   console.error('❌ Failed to upload SBOM:', err.response?.data || err.message);
//   //   process.exit(1);
//   // }
// }

// uploadSBOM();





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
