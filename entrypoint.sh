#!/bin/sh
set -e

# Render the Caddyfile from the template as root
envsubst < /data/Caddyfile.template > /data/Caddyfile

# Ensure all necessary directories exist and have correct permissions
chown -R appuser:appgroup /data
chmod -R 777 /data/logs

# Start the one-api application in the background as appuser
gosu appuser /app/curl --port 3001 &

# Wait for the one-api to be ready on port 3001
while ! nc -z 127.0.0.1 3001; do
  echo "Waiting for one-api service (curl) to be ready on port 3001..."
  sleep 1
done

echo "one-api service (curl) is ready. Starting Caddy as appuser."

# Start Caddy in the foreground as appuser
exec gosu appuser caddy run --config /data/Caddyfile --adapter caddyfile
