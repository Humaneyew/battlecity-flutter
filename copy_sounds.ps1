# PowerShell скрипт для копирования звуков из оригинальной игры
# Запустите из папки flutter_battle_city

$sourcePath = "..\godot4BattleCity\sound"
$destPath = ".\assets\sounds"

# Создаём папку если не существует
if (!(Test-Path $destPath)) {
    New-Item -ItemType Directory -Path $destPath -Force
}

# Копируем все звуковые файлы
Get-ChildItem -Path $sourcePath -Filter "*.ogg" | ForEach-Object {
    Copy-Item $_.FullName -Destination $destPath -Force
    Write-Host "Copied: $($_.Name)"
}

Get-ChildItem -Path $sourcePath -Filter "*.wav" | ForEach-Object {
    Copy-Item $_.FullName -Destination $destPath -Force
    Write-Host "Copied: $($_.Name)"
}

Write-Host "`nAll sound files copied successfully!"
Write-Host "Total files: $((Get-ChildItem $destPath).Count)"

