#!/usr/bin/env bash
set -euo pipefail

EQUIPO="${1:-EquipoX}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/Proyecto 1_${EQUIPO}.tar.gz"
STAGING="$(mktemp -d)"

cleanup() {
  rm -rf "$STAGING"
}
trap cleanup EXIT

copy_if_exists() {
  if [[ -e "$ROOT/$1" ]]; then
    mkdir -p "$STAGING/$(dirname "$1")"
    cp -r "$ROOT/$1" "$STAGING/$1"
  fi
}

for item in \
  .github src test grafana docs scripts \
  Dockerfile docker-compose.yml prometheus.yml \
  main.tf variables.tf outputs.tf .terraform.lock.hcl \
  package.json package-lock.json eslint.config.js \
  sonar-project.properties .env.example README.md sbom.cyclonedx.json
do
  copy_if_exists "$item"
done

docker save pin-proyecto1-app:latest -o "$STAGING/pin-proyecto1-app.tar"
tar -czf "$OUT" -C "$STAGING" .

echo "Entrega generada: $OUT"
