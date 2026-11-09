<#
.SYNOPSIS
    Script automatizado para subir el proyecto Amigo Secreto Familiar a GitHub.
.DESCRIPTION
    Verifica el estado del repositorio local, permite ingresar la URL remota de GitHub 
    y realiza el push a la rama main automáticamente.
#>

param(
    [string]$RepoUrl = ""
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Subida Automática a GitHub (DevOps)    " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si git está instalado
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git no está instalado o no se encuentra en el PATH."
    exit 1
}

# Verificar o solicitar URL del repositorio remoto
if ([string]::IsNullOrWhiteSpace($RepoUrl)) {
    $existingRemote = git remote get-url origin 2>$null
    if ($existingRemote) {
        Write-Host "Repositorio remoto detectado: $existingRemote" -ForegroundColor Green
        $RepoUrl = $existingRemote
    } else {
        Write-Host "Crea tu repositorio en https://github.com/new" -ForegroundColor Yellow
        $RepoUrl = Read-Host "Pega aquí la URL de tu repositorio de GitHub (ej: https://github.com/tu-usuario/amigo-secreto.git)"
    }
}

if ([string]::IsNullOrWhiteSpace($RepoUrl)) {
    Write-Warning "No se ingresó ninguna URL. Operación cancelada."
    exit 0
}

# Configurar o actualizar el remote
git remote remove origin 2>$null
git remote add origin $RepoUrl
git branch -M main

# Añadir cambios pendientes si existen
git add .
$status = git status --porcelain
if ($status) {
    git commit -m "update: sincronización y ajustes del proyecto"
}

Write-Host ""
Write-Host "Subiendo rama 'main' a GitHub..." -ForegroundColor Cyan
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "¡Repositorio subido con éxito a GitHub!" -ForegroundColor Green
    Write-Host "Ahora entra a https://vercel.com para importar tu proyecto en 1 clic." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Ocurrió un error al subir a GitHub. Si es un problema de autenticación:" -ForegroundColor Red
    Write-Host "1. Ejecuta: gh auth login" -ForegroundColor Yellow
    Write-Host "2. O usa tu Personal Access Token al pedir contraseña." -ForegroundColor Yellow
}
