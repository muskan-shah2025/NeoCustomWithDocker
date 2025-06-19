FROM prabhushan/sbom-base:1.0.2

# Install Node.js, npm, and jq
RUN apk add --no-cache nodejs npm jq

# Set working directory
WORKDIR /app

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
COPY upload-sbom.js /upload-sbom.js
COPY package.json package-lock.json ./

# Install Node dependencies
RUN npm install

# Make entrypoint executable
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]










# FROM prabhushan/sbom-base:1.0.2

# # Install jq
# RUN apk add --no-cache jq

# # Copy your entrypoint script
# COPY entrypoint.sh /entrypoint.sh
# COPY upload-sbom.js /upload-sbom.js
# RUN chmod +x /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]
