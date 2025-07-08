# Script dừng development environment
Write-Host "Stopping Flutter Hub Development Environment..." -ForegroundColor Red

# Dừng Docker containers
Write-Host "Stopping Docker containers..." -ForegroundColor Yellow
docker-compose down

# Dừng Flutter processes
Write-Host "Stopping Flutter processes..." -ForegroundColor Yellow
Get-Process -Name "flutter" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "All services stopped!" -ForegroundColor Green 