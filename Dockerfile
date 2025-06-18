FROM prabhushan/sbom-base:1.0.2

# Install jq
RUN apk add --no-cache jq

# Copy your entrypoint script
COPY entrypoint.sh /entrypoint.sh
COPY upload-sbom.js /upload-sbom.js
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]


# FROM prabhushan/sbom-base:latest
# FROM prabhushan/sbom-base:1.0.2

# # Install node and jq
# RUN apk add --no-cache jq nodejs npm

# # Set working directory
# WORKDIR /app

# # Copy package.json and install dependencies
# COPY package.json package-lock.json* ./
# RUN npm install

# # Copy your script
# COPY upload-sbom.js /upload-sbom.js

# # Set entrypoint to run the JS script with node
# ENTRYPOINT ["node", "/upload-sbom.js"]
