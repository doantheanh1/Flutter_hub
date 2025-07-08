const multer = require('multer');
const path = require('path');

// Cấu hình lưu file ảnh vào thư mục 'uploads/'
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/'); // tạo thư mục uploads trong root project
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname)); // ví dụ 1234567890.jpg
  }
});

const upload = multer({ storage: storage });
module.exports = upload;
