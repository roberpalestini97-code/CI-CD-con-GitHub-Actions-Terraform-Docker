param(
  [string]$Equipo = "EquipoX"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$OutName = "Proyecto 1_$Equipo.zip"
$OutPath = Join-Path $Root $OutName
$Staging = Join-Path $env:TEMP "pin-proyecto1-package"

if (Test-Path $Staging) {
  Remove-Item $Staging -Recurse -Force
}
New-Item -ItemType Directory -Path $Staging | Out-Null

$Include = @(
  ".github",
  "src",
  "test",
  "grafana",
  "docs",
  "scripts",
  "Dockerfile",
  "docker-compose.yml",
  "prometheus.yml",
  "main.tf",
  "variables.tf",
  "outputs.tf",
  ".terraform.lock.hcl",
  "package.json",
  "package-lock.json",
  "eslint.config.js",
  "sonar-project.properties",
  ".env.example",
  "README.md",
  "sbom.cyclonedx.json"
)

foreach ($item in $Include) {
  $source = Join-Path $Root $item
  if (Test-Path $source) {
    Copy-Item $source (Join-Path $Staging $item) -Recurse -Force
  }
}

$imageTar = Join-Path $Staging "pin-proyecto1-app.tar"
docker save pin-proyecto1-app:latest -o $imageTar

if (Test-Path $OutPath) {
  Remove-Item $OutPath -Force
}

Compress-Archive -Path (Join-Path $Staging "*") -DestinationPath $OutPath -Force
Remove-Item $Staging -Recurse -Force

Write-Host "Entrega generada: $OutPath"
