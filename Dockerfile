# Etapa 1: dependencias de desarrollo para ejecutar tests
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# Etapa 2: validación (tests)
FROM deps AS test
COPY src ./src
COPY test ./test
COPY eslint.config.js ./
RUN npm run lint && npm test

# Etapa 3: dependencias de producción
FROM node:20-alpine AS prod-deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Etapa 4: imagen final mínima
FROM node:20-alpine AS production
RUN addgroup -g 1001 -S appgroup \
  && adduser -S appuser -u 1001 -G appgroup
WORKDIR /app
COPY --from=prod-deps /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src
USER appuser
EXPOSE 3000
ENV NODE_ENV=production \
    PORT=3000 \
    APP_NAME="PIN Proyecto 1"
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/health || exit 1
CMD ["node", "src/server.js"]
