FROM prabhushan/sbom-base:1.0.2

RUN apk add --no-cache nodejs npm jq

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
COPY upload-sbom.js /app/upload-sbom.js
COPY package.json package-lock.json /app/

RUN npm install

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
