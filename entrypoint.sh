#!/bin/sh
set -e

# Render the Caddyfile from the template
envsubst < /etc/caddy/Caddyfile.template > /etc/caddy/Caddyfile

# Start the one-api application in the background
# The port is hardcoded to 3001 as per the Caddyfile
/app/curl --port 3001 &

# Wait for the one-api to be ready on port 3001
while ! nc -z 127.0.0.1 3001; do
  echo "Waiting for one-api service (curl) to be ready on port 3001..."
  sleep 1
done

echo "one-api service (curl) is ready. Starting Caddy."

# Start Caddy in the foreground
# Caddy will use the generated Caddyfile
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
