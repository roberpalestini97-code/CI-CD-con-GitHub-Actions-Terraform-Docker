# Evidencias para la rúbrica

Colocá aquí capturas de pantalla con estos nombres sugeridos:

| Archivo | Contenido |
|---------|-----------|
| `01-github-actions.png` | Workflow CI/CD en verde (jobs test, sonarqube, security, docker, deploy) |
| `02-sonarqube.png` | Quality gate / análisis SonarQube |
| `03-snyk.png` | Resultado del escaneo Snyk sin vulnerabilidades high+ |
| `04-grafana-dashboard.png` | Dashboard **PIN Proyecto 1 — Observabilidad** con métricas |
| `05-prometheus-targets.png` | Prometheus → Status → Targets (todos UP) |
| `06-terraform-output.png` | Salida de `terraform output` tras apply |

Para generar la captura de Grafana localmente:

1. `docker compose up --build -d`
2. Abrí http://localhost:3002 (admin / admin)
3. Dashboards → carpeta PIN → **PIN Proyecto 1 — Observabilidad**

El archivo `04-grafana-dashboard.png` puede generarse automáticamente tras levantar el stack si Grafana responde en el puerto 3002.
