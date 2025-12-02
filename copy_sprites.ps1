# PowerShell скрипт для копирования спрайтов из оригинальной игры
# Запустите из папки flutter_battle_city

$sourcePath = "..\godot4BattleCity\sprite"
$destPath = ".\assets\sprites"

# Создаём папку если не существует
if (!(Test-Path $destPath)) {
    New-Item -ItemType Directory -Path $destPath -Force
}

# Копируем все PNG файлы
Get-ChildItem -Path $sourcePath -Filter "*.png" | ForEach-Object {
    Copy-Item $_.FullName -Destination $destPath -Force
    Write-Host "Copied: $($_.Name)"
}

Write-Host "`nAll sprite files copied successfully!"
Write-Host "Total files: $((Get-ChildItem $destPath -Filter '*.png').Count)"

