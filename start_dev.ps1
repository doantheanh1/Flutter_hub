# Script khởi động development environment
Write-Host "🚀 Khởi động Flutter Hub Development Environment..." -ForegroundColor Green

# Kiểm tra Docker có chạy không
Write-Host "📦 Kiểm tra Docker..." -ForegroundColor Yellow
docker --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker chưa chạy! Vui lòng khởi động Docker Desktop" -ForegroundColor Red
    exit 1
}

# Dừng containers cũ nếu có
Write-Host "🛑 Dừng containers cũ..." -ForegroundColor Yellow
docker-compose down

# Khởi động API + MongoDB
Write-Host "🔧 Khởi động API + MongoDB..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; docker-compose up --build"

# Đợi API khởi động
Write-Host "⏳ Đợi API khởi động..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Kiểm tra API đã sẵn sàng chưa
$maxAttempts = 30
$attempt = 0
do {
    $attempt++
    Write-Host "🔍 Kiểm tra API (lần $attempt/$maxAttempts)..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api-docs" -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ API đã sẵn sàng!" -ForegroundColor Green
            break
        }
    } catch {
        Write-Host "⏳ API chưa sẵn sàng, đợi..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "❌ API không khởi động được sau $maxAttempts lần thử" -ForegroundColor Red
    exit 1
}

# Khởi động Flutter mobile
Write-Host "📱 Khởi động Flutter mobile app..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD/flutterhub'; flutter run"

Write-Host "🎉 Development environment đã khởi động!" -ForegroundColor Green
Write-Host "📊 API: http://localhost:3000/api-docs" -ForegroundColor Cyan
Write-Host "📱 Flutter: Đang chạy trên emulator" -ForegroundColor Cyan
Write-Host "💡 Nhấn Ctrl+C để dừng tất cả" -ForegroundColor Yellow 