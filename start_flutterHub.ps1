# Script chạy trong terminal Cursor hiện tại
Write-Host "Starting Flutter Hub in Cursor..." -ForegroundColor Green

# Dừng containers cũ
Write-Host "Stopping old containers..." -ForegroundColor Yellow
docker-compose down

# Khởi động API + MongoDB trong background
Write-Host "Starting API + MongoDB..." -ForegroundColor Yellow
Start-Job -ScriptBlock {
    Set-Location $using:PWD
    docker-compose up --build
}

# Đợi API khởi động
Write-Host "Waiting for API to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Khởi động Flutter trong background
Write-Host "Starting Flutter mobile..." -ForegroundColor Yellow
Start-Job -ScriptBlock {
    Set-Location "$using:PWD/flutterhub"
    flutter run
}

Write-Host "All services started!" -ForegroundColor Green
Write-Host "API: http://localhost:3000/api-docs" -ForegroundColor Cyan
Write-Host "Flutter: Running on emulator" -ForegroundColor Cyan
Write-Host "Use Get-Job to check status" -ForegroundColor Yellow 