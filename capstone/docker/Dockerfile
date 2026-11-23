# ============================================================
# Multi-stage Dockerfile - DevOps Capstone App
# Stage 1: Build/test  Stage 2: Production image
# ============================================================

# --- Stage 1: Build ---
FROM node:20-alpine3.20 AS builder

WORKDIR /app

# Copy dependency files first (layer caching)
COPY app/package*.json ./
RUN npm ci --only=production

# --- Stage 2: Production ---
FROM node:20-alpine3.20 AS production

# Security: create non-root user
RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup

WORKDIR /app

# Copy production node_modules from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application source
COPY app/src ./src
COPY app/package.json ./package.json

# Set ownership
RUN chown -R nodeuser:nodegroup /app

USER nodeuser

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

ARG BUILD_VERSION=1.0.0
ENV APP_VERSION=${BUILD_VERSION}
ENV NODE_ENV=production

CMD ["node", "src/index.js"]
