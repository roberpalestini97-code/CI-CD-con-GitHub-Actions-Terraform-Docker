# PIN Proyecto 1 — Aplicación + Docker

Aplicación base para el **Proyecto Integrador Final (PIN)**: CI/CD con GitHub Actions, Terraform y Docker.

## Responsable

**Persona 3** — Docker + Aplicación

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

## Próximos pasos del equipo

- **Persona 1**: pipeline GitHub Actions (build, test, lint, security, deploy)
- **Persona 2**: infraestructura con Terraform
- **Persona 4**: Prometheus, Grafana y documentación final
