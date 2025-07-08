@echo off
echo 🚀 Khởi động Flutter Hub Development...

REM Khởi động API trong background
start "API" cmd /k "docker-compose up --build"

REM Đợi 10 giây
timeout /t 10 /nobreak

REM Khởi động Flutter
start "Flutter" cmd /k "cd flutterhub && flutter run"

echo ✅ Đã khởi động API và Flutter!
echo 📊 API: http://localhost:3000/api-docs
echo 📱 Flutter: Đang chạy trên emulator 