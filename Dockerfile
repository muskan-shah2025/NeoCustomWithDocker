FROM prabhushan/sbom-base:1.0.2

RUN apk add --no-cache jq nodejs npm

WORKDIR /app

# Copy package files and install deps
COPY package.json package-lock.json ./
RUN npm install

# Copy your scripts
COPY entrypoint.sh upload-sbom.js ./

RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]







# FROM prabhushan/sbom-base:1.0.2

# # Install jq
# RUN apk add --no-cache jq

# # Copy your entrypoint script
# COPY entrypoint.sh /entrypoint.sh
# COPY upload-sbom.js /upload-sbom.js
# RUN chmod +x /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]
