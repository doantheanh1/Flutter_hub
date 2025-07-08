# Hướng dẫn Test Like System

## Các thay đổi đã thực hiện:

### Backend (Node.js)
1. **Sửa logic like/unlike** trong `post.controller.js`:
   - Kiểm tra user đã like chưa trước khi thêm like
   - Kiểm tra user đã like chưa trước khi unlike
   - Xử lý lỗi tốt hơn

2. **Thêm endpoint mới**:
   - `GET /api/posts/:id/like-status?userId=xxx` - Kiểm tra trạng thái like

### Frontend (Flutter)
1. **Cải thiện LikeBloc**:
   - Xử lý response tốt hơn
   - Thêm event `CheckLikeStatusEvent`
   - Thêm state `LikeStatusLoaded`

2. **Cải thiện UI**:
   - Thêm loading state cho like button
   - Hiển thị thông báo lỗi tốt hơn
   - Cập nhật UI sau khi like/unlike thành công

## Cách test:

### 1. Test Backend API
```bash
# Start server
cd flutterhub_api
npm start

# Test like
curl -X POST http://localhost:3000/api/posts/POST_ID/like \
  -H "Content-Type: application/json" \
  -d '{"userId": "USER_ID"}'

# Test unlike
curl -X POST http://localhost:3000/api/posts/POST_ID/unlike \
  -H "Content-Type: application/json" \
  -d '{"userId": "USER_ID"}'

# Test check like status
curl http://localhost:3000/api/posts/POST_ID/like-status?userId=USER_ID
```

### 2. Test Frontend
1. Chạy app Flutter
2. Đăng nhập bằng Google
3. Tạo một bài viết
4. Thử like/unlike bài viết
5. Kiểm tra:
   - Icon thay đổi đúng không
   - Số like tăng/giảm đúng không
   - Loading state hiển thị khi đang xử lý
   - Thông báo lỗi nếu có

## Các vấn đề đã sửa:

1. **Logic like/unlike bị lỗi**: Đã sửa để kiểm tra trạng thái trước khi thực hiện
2. **UI không cập nhật**: Đã thêm fetch lại posts sau khi like/unlike thành công
3. **Không có loading state**: Đã thêm loading indicator
4. **Error handling kém**: Đã cải thiện thông báo lỗi

## Lưu ý:
- Đảm bảo backend server đang chạy
- Kiểm tra kết nối mạng
- Xem console log để debug nếu có lỗi 