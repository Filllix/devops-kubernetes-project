# -------------------------
# Build stage
# -------------------------
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .


# -------------------------
# Runtime stage
# -------------------------
FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder --chown=node:node /app /app

# npm is only required during build, not at runtime
RUN rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm \
    && rm -f /usr/local/bin/npx

USER node

EXPOSE 3000

CMD ["node", "server.js"]