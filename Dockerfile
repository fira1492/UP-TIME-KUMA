# Standalone Dockerfile for Render deployment
FROM node:26-bookworm-slim

WORKDIR /app

# Install dependencies for better-sqlite3 and other native modules
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    git \
    curl \
    ca-certificates \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --omit=dev

# Copy application files
COPY . .

# Build frontend
RUN npm run build

# Create data directory
RUN mkdir -p /app/data

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=60s --timeout=30s --start-period=180s --retries=5 \
    CMD node extra/simple-dns-server.js || exit 1

# Set environment
ENV NODE_ENV=production
ENV UPTIME_KUMA_IS_CONTAINER=1

# Start application
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "server/server.js"]
