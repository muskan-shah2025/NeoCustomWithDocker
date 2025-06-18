
FROM prabhushan/sbom-base:latest

RUN apk add --no-cache jq nodejs npm

COPY upload-sbom.js /upload-sbom.js
RUN npm install axios form-data

ENTRYPOINT ["node", "/upload-sbom.js"]
