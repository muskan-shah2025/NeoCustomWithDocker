# FROM prabhushan/sbom-base:1.0.2

# # Install jq
# RUN apk add --no-cache jq

# # Copy your entrypoint script
# COPY entrypoint.sh /entrypoint.sh
# COPY upload-sbom.js /upload-sbom.js
# RUN chmod +x /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]


FROM prabhushan/sbom-base:1.0.2

# Install dependencies
RUN apk add --no-cache jq nodejs npm

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
COPY upload-sbom.js /upload-sbom.js

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
