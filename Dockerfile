# FROM prabhushan/sbom-base:latest

# # Install jq
# RUN apk add --no-cache jq

# # Copy your entrypoint script
# COPY entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]

# FROM prabhushan/sbom-base:latest
FROM prabhushan/sbom-base:1.0.2

# Install jq and Node.js
RUN apk add --no-cache jq nodejs npm

# Copy the script
COPY upload-sbom.js /upload-sbom.js

# (Optional) If you want to keep entrypoint.sh as well, you can copy it:
# COPY entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

# Set entrypoint to run the JS script with node
ENTRYPOINT ["node", "/upload-sbom.js"]
