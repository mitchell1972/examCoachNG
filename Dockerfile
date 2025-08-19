# Multi-stage Dockerfile for ExamCoach Backend

# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY server/package*.json ./
RUN npm ci --only=production

# Copy TypeScript files and build
COPY server/tsconfig.json ./
COPY server/src ./src
RUN npm install -g typescript
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy built application
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --chown=nodejs:nodejs server/package*.json ./
COPY --chown=nodejs:nodejs server/private ./private
COPY --chown=nodejs:nodejs server/migrations ./migrations

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {r.statusCode === 200 ? process.exit(0) : process.exit(1)})"

# Start application with dumb-init
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/app.js"]
