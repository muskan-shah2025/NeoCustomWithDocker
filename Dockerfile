FROM prabhushan/sbom-base:1.0.2

# Install jq and Node.js + npm (if not present)
RUN apk add --no-cache jq nodejs npm

# Set working directory
WORKDIR /app

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
COPY upload-sbom.js /upload-sbom.js
COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json

# Install Node.js dependencies (axios, form-data)
RUN npm install

# Make entrypoint executable
RUN chmod +x /entrypoint.sh

# Entrypoint script
ENTRYPOINT ["/entrypoint.sh"]









# FROM prabhushan/sbom-base:1.0.2

# # Install jq
# RUN apk add --no-cache jq

# # Copy your entrypoint script
# COPY entrypoint.sh /entrypoint.sh
# COPY upload-sbom.js /upload-sbom.js
# RUN chmod +x /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]
