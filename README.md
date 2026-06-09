# PIN Proyecto 1 — Aplicación + Docker

Aplicación base para el **Proyecto Integrador Final (PIN)**: CI/CD con GitHub Actions, Terraform y Docker.

## Endpoints

| Ruta | Descripción |
|------|-------------|
| `GET /` | Mensaje de bienvenida |
| `GET /health` | Healthcheck (usado por Docker) |
| `GET /api/info` | Información de la aplicación |

## Requisitos

- Node.js 20+
- Docker y Docker Compose

## Ejecución local (sin Docker)

```bash
cp .env.example .env
npm install
npm test
npm start
```

La app queda disponible en `http://localhost:3000`.

## Ejecución con Docker

```bash
docker compose up --build
```

Verificar healthcheck:

```bash
curl http://localhost:3000/health
```

## Estructura del proyecto

```
.
├── src/              # Código de la aplicación
├── test/             # Tests automatizados
├── Dockerfile        # Build multistage
├── docker-compose.yml
└── .env.example      # Variables de entorno de referencia
```
