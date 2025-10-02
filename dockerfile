# ------------------------
# Stage 1 — Builder
# ------------------------
    FROM node:20-alpine AS builder
    WORKDIR /app
    
    # Copy package files and install all deps (including dev for build/tests)
    COPY package*.json ./
    RUN npm ci
    
    # Copy source code and tsconfig
    COPY tsconfig.json ./
    COPY src ./src
    
    # Build TypeScript -> dist
    RUN npm run build
    
    # Optionally run tests here (uncomment if you want tests in build stage)
    # RUN npm test
    
    
    # ------------------------
    # Stage 2 — Production
    # ------------------------
    FROM node:20-alpine
    WORKDIR /app
    
    # Copy only package.json and lock file for prod dependencies
    COPY package*.json ./
    RUN npm ci --omit=dev
    
    # Copy compiled output from builder
    COPY --from=builder /app/dist ./dist
    
    # Copy any runtime assets (uncomment if needed)
    # COPY --from=builder /app/uploads ./uploads
    # COPY --from=builder /app/prisma ./prisma
    
    # Environment setup
    ENV NODE_ENV=production
    EXPOSE 3000
    
    # Start the app
    CMD ["node", "dist/index.js"]
    