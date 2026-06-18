# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es este proyecto

App base del **Proyecto Integrador Final (PIN)** para practicar CI/CD con GitHub Actions, Terraform y Docker. La aplicación en sí es deliberadamente mínima — su rol es servir de objeto de despliegue para la infraestructura y el pipeline.

**Estado actual:** existen la app Node.js, el empaquetado Docker y el pipeline de **GitHub Actions** (`.github/workflows/ci-cd.yml`). **Todavía no hay** archivos Terraform — son trabajo pendiente. El `.dockerignore` ya contempla `*.tfstate`, anticipando esa pieza.

## Comandos

```bash
npm test          # Ejecuta tests con el runner nativo (node --test)
npm run lint      # ESLint sobre src y test
npm start         # Arranca el servidor (src/server.js)
npm run dev       # Igual que start, con --watch (reinicio en cambios)

# Un solo archivo de test
node --test test/app.test.js

# Docker
docker compose up --build          # build (target: production) + run
curl http://localhost:3000/health  # verificar healthcheck
```

No hay framework de test externo: se usa `node:test` + `node:assert`. No hay paso de build/transpilación — el código se ejecuta tal cual.

## Arquitectura

- **`src/app.js`** — Factory `createApp(config)` que devuelve un `http.Server` nativo (sin Express). El ruteo es un encadenamiento manual de `if (method && url)`; cualquier ruta no contemplada cae en un 404 JSON. La factory acepta `config` por inyección (p. ej. `appName`) **con prioridad sobre las variables de entorno** — este patrón es lo que permite testear la app sin depender del entorno.
- **`src/server.js`** — Único punto que hace `listen`. Importa la factory y bindea a `0.0.0.0` en `PORT` (default 3000). Mantener `app.js` libre de `listen` es intencional: los tests instancian su propio server en un puerto efímero (`listen(0)`).
- **`test/app.test.js`** — Levanta la app en puerto efímero y la golpea por HTTP real. Al agregar rutas en `app.js`, añadir aquí su caso correspondiente.

Endpoints: `GET /` (bienvenida), `GET /health` (status + uptime, lo consume el HEALTHCHECK de Docker), `GET /api/info` (nombre/versión/entorno).

## Docker

El `Dockerfile` es multistage e incluye una **etapa `test` que corre `npm run lint && npm test` durante el build** — un build de imagen falla si lint o tests fallan. La imagen `production` final corre como usuario no-root (`appuser`, uid 1001) y trae un HEALTHCHECK que pega a `/health` con `wget`. `docker-compose.yml` construye con `target: production`.

## CI/CD (GitHub Actions)

`.github/workflows/ci-cd.yml` corre en push a `main`, tags `v*` y PRs a `main`. Jobs:

1. **test** — `npm ci` + `npm run lint` + `npm test`.
2. **sonarqube** — análisis con `sonarqube-scan-action` (config en `sonar-project.properties`). Secrets: `SONAR_TOKEN`, `SONAR_HOST_URL`.
3. **security** — `snyk/actions/node` con `--severity-threshold=high`. Secret: `SNYK_TOKEN`.
4. **docker** — solo en push (no PRs). Build del target `production` y push a **GHCR** (`ghcr.io/<owner>/<repo>`) con `docker/build-push-action` + caché de Buildx por GHA. Usa `GITHUB_TOKEN` (no requiere secret extra). Para Docker Hub, cambiar el login y el `images:` del paso de metadata. Genera **SBOM** de dos formas: attestation adjunta a la imagen (`sbom: true` + `provenance: mode=max`) y un archivo `sbom.cyclonedx.json` (CycloneDX, vía `anchore/sbom-action`) subido como artifact del workflow.

Nota: `docker/metadata-action` pasa el nombre de la imagen a minúsculas, necesario porque el repo tiene mayúsculas y GHCR las rechaza. El build del target `production` **no** ejecuta la etapa `test` del Dockerfile (no está en su grafo de dependencias); por eso los tests corren en el job `test` aparte.

## Convenciones

- CommonJS (`require`/`module.exports`), no ESM. ESLint está fijado a `sourceType: 'commonjs'`.
- Node 20+ (ver `engines`). Se usan APIs nativas con prefijo `node:` (`node:http`, `node:test`).
- Variables de entorno: `PORT`, `NODE_ENV`, `APP_NAME` (ver `.env.example`). El código siempre provee defaults, así que la app corre sin `.env`.
- Mensajes de la app y descripciones en español.
