# PowerShell скрипт для копирования уровней из оригинальной игры
# Запустите из папки flutter_battle_city

$sourcePath = "..\godot4BattleCity\level"
$destPath = ".\assets\levels"

# Создаём папку если не существует
if (!(Test-Path $destPath)) {
    New-Item -ItemType Directory -Path $destPath -Force
}

# Копируем все JSON файлы
Get-ChildItem -Path $sourcePath -Filter "*.json" | ForEach-Object {
    Copy-Item $_.FullName -Destination $destPath -Force
    Write-Host "Copied: $($_.Name)"
}

Write-Host "`nAll level files copied successfully!"
Write-Host "Total files: $((Get-ChildItem $destPath -Filter '*.json').Count)"

