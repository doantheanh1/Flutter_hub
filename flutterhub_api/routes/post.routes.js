const express = require('express');
const router = express.Router();
const postController = require('../controllers/post.controller');
const upload = require('../middlewares/upload.middleware');

// @route POST /api/posts
router.post('/', upload.array('images', 10), postController.createPost); // Sửa ở đây

// @route GET /api/posts
router.get('/', postController.getAllPosts);

// @route DELETE /api/posts/:id
router.delete('/:id', postController.deletePost);

// post.routes.js
router.post('/:id/like', postController.likePost);

// post.routes.js
router.post('/:id/unlike', postController.unlikePost);

// Thêm bình luận mới
router.post('/:postId/comments', postController.addComment);

// Sửa bình luận
router.put('/:postId/comments/:commentId', postController.editComment);

// Xóa bình luận
router.delete('/:postId/comments/:commentId', postController.deleteComment);

// Lấy danh sách bình luận cho 1 bài viết
router.get('/:postId/comments', postController.getComments);

// Kiểm tra trạng thái like của user cho một bài viết
router.get('/:id/like-status', postController.checkLikeStatus);

module.exports = router;