# FlutterHub - Hướng dẫn chạy dự án

## Yêu cầu

- Docker & Docker Compose
- NodeJS (nếu muốn chạy API ngoài Docker)
- Flutter SDK (nên dùng bản mới nhất)
- PowerShell (Windows) hoặc Terminal (Mac/Linux)

---

## Khởi động nhanh (khuyên dùng)

**Chạy cả API + MongoDB + Flutter mobile chỉ với 1 lệnh:**

```terminal
.\start_flutterHub.ps1
```

- API + MongoDB sẽ chạy bằng Docker (background job)
- Flutter mobile sẽ chạy trên emulator hoặc thiết bị thật
- Có thể kiểm tra API docs tại: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)

---

## Dừng toàn bộ dịch vụ

```terminal
.\stop_dev.ps1
```

---

## Các script khác

- `.\start_simple.ps1` - Chạy API + Flutter, mỗi service mở 1 cửa sổ terminal mới
- `.\start_sequential.ps1` - Chạy tuần tự: API xong đến Flutter (dễ debug)
- `start.bat` - Batch file để chạy (Windows)

---

## Thông tin thêm

- **API**: NodeJS/Express, tài liệu Swagger tại `/api-docs`
- **Database**: MongoDB (chạy bằng Docker)
- **Flutter**: Chạy mobile app (không cần web)

---

## Troubleshooting

- Nếu không thấy bài viết/bình luận, hãy tạo mới qua app hoặc Swagger UI.
- Nếu gặp lỗi port, hãy kiểm tra Docker Desktop đã chạy chưa.
- Nếu push lên GitHub bị lỗi, hãy kiểm tra `.gitignore` đã chuẩn chưa.

---

## Đóng góp & phát triển

- Fork, clone repo về máy
- Tạo branch mới cho mỗi tính năng/bugfix
- Pull request khi hoàn thành

---

**Chúc bạn code vui vẻ với FlutterHub!** 
