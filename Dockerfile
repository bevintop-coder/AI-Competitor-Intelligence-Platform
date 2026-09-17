# ================================
# Stage 1: Build Frontend
# ================================
FROM node:20-slim AS frontend-builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY client ./client

WORKDIR /app/client
RUN npm install
RUN npm run build


# ================================
# Stage 2: Production Backend
# ================================
FROM node:20-slim

WORKDIR /app

# Install Chromium dependencies for Puppeteer
RUN apt-get update && apt-get install -y \
    chromium \
    ca-certificates \
    fonts-liberation \
    fonts-noto-color-emoji \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Tell Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install backend dependencies
COPY server/package*.json ./server/
WORKDIR /app/server
RUN npm install --omit=dev

# Copy backend source
COPY server/src ./src

# Copy built frontend
COPY --from=frontend-builder /app/client/dist /app/client/dist

WORKDIR /app

# Create directory for SQLite/database data
RUN mkdir -p /app/data

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

# Start backend
CMD ["node", "server/src/index.js"]
