FROM prabhushan/sbom-base:latest

# Install jq
RUN apk add --no-cache jq

# Copy your entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
