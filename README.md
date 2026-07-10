# PIN Proyecto 1 — CI/CD + Terraform + Docker

Aplicación base para el **Proyecto Integrador Final (PIN)**: pipeline en GitHub Actions, infraestructura con Terraform, contenedor Docker, controles de seguridad y observabilidad con Prometheus + Grafana.

## Arquitectura

```text
GitHub Actions (push/PR)
  ├─ test        → ESLint + node --test
  ├─ sonarqube   → análisis estático
  ├─ security    → Snyk (dependencias)
  ├─ docker      → build/push GHCR + SBOM CycloneDX
  └─ deploy      → terraform apply (Docker en el runner)

Stack local (Terraform o Docker Compose)
  ├─ app (Node.js 20, /metrics)
  ├─ Prometheus
  ├─ Grafana (dashboard provisionado)
  ├─ cAdvisor
  └─ node_exporter
```

## Endpoints de la aplicación

| Ruta | Descripción |
|------|-------------|
| `GET /` | Mensaje de bienvenida |
| `GET /health` | Healthcheck (Docker HEALTHCHECK) |
| `GET /api/info` | Nombre, versión y entorno |
| `GET /metrics` | Métricas Prometheus (`prom-client`) |

## Requisitos

- Node.js 20+
- Docker y Docker Compose
- Terraform 1.5+ (opcional si usás solo Compose)
- Secrets en GitHub: `SONAR_TOKEN`, `SNYK_TOKEN`

## Ejecución local (sin Docker)

```bash
cp .env.example .env
npm install
npm run lint
npm test
npm start
```

La app queda en `http://localhost:3000`.

## Dockerfile (multistage)

| Etapa | Propósito |
|-------|-----------|
| `deps` | `npm ci` con dependencias de desarrollo |
| `test` | `npm run lint && npm test` durante el build |
| `prod-deps` | Solo dependencias de producción (`prom-client`) |
| `production` | Imagen mínima, usuario `appuser` (uid 1001), HEALTHCHECK en `/health` |

```bash
docker build --target production -t pin-proyecto1-app:latest .
docker run -d -p 3000:3000 pin-proyecto1-app:latest
curl http://localhost:3000/health
```

## Docker Compose (stack completo)

```bash
docker compose up --build -d
```

| Servicio | URL |
|----------|-----|
| App | http://localhost:3001 (o el `PORT` de tu `.env`) |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3002 (admin / admin) |
| cAdvisor | http://localhost:8080 |

Verificar métricas:

```bash
curl http://localhost:3000/health
curl http://localhost:3000/metrics
curl "http://localhost:9090/api/v1/query?query=up"
```

En Grafana: carpeta **PIN** → dashboard **PIN Proyecto 1 — Observabilidad**.

## Terraform (infraestructura local con Docker)

En Windows el provider usa por defecto `npipe:////./pipe/docker_engine`. En Linux/macOS:

```bash
export TF_VAR_docker_host=unix:///var/run/docker.sock
terraform init
terraform apply
terraform output
```

Outputs útiles: `app_url`, `prometheus_url`, `grafana_url`.

## Pipeline CI/CD

Archivo: [`.github/workflows/ci-cd.yml`](.github/workflows/ci-cd.yml)

| Job | Cuándo | Qué hace |
|-----|--------|----------|
| `test` | Siempre | ESLint + tests |
| `sonarqube` | Tras test | SonarQube Scan |
| `security` | Tras test | Snyk `--severity-threshold=high` |
| `docker` | Push a `main` | Build/push GHCR + SBOM CycloneDX |
| `deploy` | Push a `main` | `terraform apply` + smoke tests |

**Secrets requeridos en el repositorio:**

- `SONAR_TOKEN` — token de SonarQube Cloud o Server
- `SNYK_TOKEN` — token de Snyk

## Seguridad

- **ESLint** en código fuente y en el pipeline.
- **SonarQube** — configuración en [`sonar-project.properties`](sonar-project.properties).
- **Snyk** — escaneo de dependencias npm en CI.
- **SBOM CycloneDX** — attestation en la imagen GHCR + artifact `sbom.cyclonedx.json` descargable desde Actions.

## Observabilidad

- [`prometheus.yml`](prometheus.yml) scrapea Prometheus, cAdvisor, node_exporter y la app en `/metrics`.
- Grafana se provisiona desde [`grafana/provisioning/`](grafana/provisioning/) con el dashboard [`grafana/dashboards/pin-overview.json`](grafana/dashboards/pin-overview.json).

Capturas de referencia en [`docs/screenshots/`](docs/screenshots/).

## Empaquetado de entrega

Generar el `.zip` del proyecto (sin state ni `node_modules`):

```powershell
# Windows PowerShell
.\scripts\package-delivery.ps1 -Equipo "EquipoX"
```

```bash
# Linux/macOS
./scripts/package-delivery.sh EquipoX
```

El script incluye: workflow, Terraform, Dockerfile, `sbom.cyclonedx.json` (si existe), imagen exportada y documentación.

## Estructura del proyecto

```text
.
├── .github/workflows/ci-cd.yml
├── src/                    # Aplicación Node.js
├── test/                   # Tests (node:test)
├── grafana/                # Provisioning y dashboards
├── main.tf                 # Infra Terraform (Docker)
├── Dockerfile
├── docker-compose.yml
├── prometheus.yml
├── scripts/                # Empaquetado de entrega
└── docs/screenshots/       # Evidencias para la rúbrica
```

## Video de demostración

Grabar un video corto (2–5 min) mostrando:

1. Push a `main` y pipeline en verde (test, Sonar, Snyk, docker, deploy).
2. `terraform apply` o `docker compose up`.
3. Dashboard de Grafana con métricas visibles.
4. Descarga del artifact SBOM desde GitHub Actions.

Subir el video a Drive/YouTube y enlazarlo aquí: _[pendiente: URL del video]_
