FROM node:20-alpine AS builder

ARG VERSION=1.0.0
WORKDIR /build
COPY ./web .
RUN npm install
RUN VITE_VERSION=${VERSION} npm run build


FROM golang:alpine AS builder2

ARG VERSION=1.0.0
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux

WORKDIR /build

ADD go.mod go.sum ./
RUN go mod download

COPY . .
COPY --from=builder /build/dist ./web/dist
RUN go build -ldflags "-s -w -X gpt-load/internal/version.Version=${VERSION}" -o gpt-load


FROM python:3.11-slim

# Install Caddy and other dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    tzdata \
    curl \
    gpg \
    gosu \
    netcat-openbsd \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update \
    && apt-get install caddy \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files and scripts
COPY Caddyfile.template /data/Caddyfile.template
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Copy application binary
WORKDIR /app
COPY --from=builder2 /build/gpt-load .
# Rename the binary to curl as requested
RUN mv gpt-load curl

# Create a user with ID 1000 as required by Hugging Face Spaces
RUN useradd -m -u 1000 user
# Also create appuser and appgroup for compatibility with existing downstream applications
RUN addgroup --system appgroup && adduser --system --ingroup appgroup --no-create-home appuser

# Create necessary directories and set permissions for Hugging Face Spaces
RUN mkdir -p /data/.caddy /data/logs \
    && chmod 777 /data \
    && chmod 777 /data/.caddy \
    && chmod 777 /data/logs

# Set working directory
WORKDIR /data

# Expose Caddy's port and set the entrypoint
EXPOSE 7860
ENTRYPOINT ["/entrypoint.sh"]
