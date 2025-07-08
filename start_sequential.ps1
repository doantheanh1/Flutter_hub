# Script chạy tuần tự trong Cursor
Write-Host "🚀 Khởi động Flutter Hub..." -ForegroundColor Green

# Dừng containers cũ
Write-Host "🛑 Dừng containers cũ..." -ForegroundColor Yellow
docker-compose down

# Khởi động API
Write-Host "🔧 Khởi động API + MongoDB..." -ForegroundColor Yellow
Write-Host "💡 Nhấn Ctrl+C để dừng API và chuyển sang Flutter" -ForegroundColor Yellow
docker-compose up --build 