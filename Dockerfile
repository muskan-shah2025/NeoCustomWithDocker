# FROM prabhushan/sbom-base:latest

# # Install jq
# RUN apk add --no-cache jq

# # Copy your entrypoint script
# COPY entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]

FROM prabhushan/sbom-base:latest

# Install jq and Node.js
RUN apk add --no-cache jq nodejs npm

# Copy entrypoint and JS parser
COPY entrypoint.sh /entrypoint.sh
# COPY upload-sbom.js /upload-sbom.js
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

