# Simple development startup script
Write-Host "Starting Flutter Hub Development..." -ForegroundColor Green

# Stop old containers
Write-Host "Stopping old containers..." -ForegroundColor Yellow
docker-compose down

# Start API + MongoDB
Write-Host "Starting API + MongoDB..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; docker-compose up --build"

# Wait for API
Write-Host "Waiting for API to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Start Flutter
Write-Host "Starting Flutter mobile app..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD/flutterhub'; flutter run"

Write-Host "Development environment started!" -ForegroundColor Green
Write-Host "API: http://localhost:3000/api-docs" -ForegroundColor Cyan
Write-Host "Flutter: Running on emulator" -ForegroundColor Cyan 