const Post = require('../models/post.model');
const fs = require('fs');
const path = require('path');

// Tạo bài viết mới
exports.createPost = async (req, res) => {
  console.log(req.body); // Kiểm tra các trường nhận được
console.log(req.files); // Kiểm tra file nhận được
  try {
    const { title, content, author, avatarUrl, authorId } = req.body; // <-- Lấy thêm authorId
    const imageUrls = req.files ? req.files.map(file => `/uploads/${file.filename}`) : [];

    if (imageUrls.length === 0) {
      return res.status(400).json({ message: 'Vui lòng upload ít nhất một ảnh' });
    }
    if (!avatarUrl) {
      return res.status(400).json({ message: 'Vui lòng truyền avatarUrl' });
    }
    if (!authorId) {
      return res.status(400).json({ message: 'Vui lòng truyền authorId' });
    }
    const newPost = await Post.create({ title, content, author, authorId, imageUrls, avatarUrl });
    res.status(201).json(newPost);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Lấy danh sách bài viết
exports.getAllPosts = async (req, res) => {
  try {
    const posts = await Post.find().sort({ createdAt: -1 });
    res.json(posts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Xóa bài viết
exports.deletePost = async (req, res) => {
  try {
    const post = await Post.findByIdAndDelete(req.params.id);
    if (!post) {
      return res.status(404).json({ message: 'Không tìm thấy bài viết' });
    }

    // Xóa từng file ảnh vật lý
    if (post.imageUrls && Array.isArray(post.imageUrls)) {
      post.imageUrls.forEach(imageUrl => {
        // Đường dẫn tuyệt đối tới file ảnh
        const filePath = path.join(__dirname, '..', imageUrl);
        fs.unlink(filePath, err => {
          // Không cần trả lỗi nếu file không tồn tại
        });
      });
    }

    res.json({ message: 'Xóa bài viết và ảnh thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error });
  }
};

// Like bài viết
exports.likePost = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) return res.status(404).json({ message: 'Post not found' });

    const userId = req.body.userId;
    
    // Kiểm tra xem user đã like chưa
    if (post.likedBy.includes(userId)) {
      return res.status(400).json({ message: 'Bạn đã like bài viết này rồi' });
    }

    // Thêm like
    post.likes = (post.likes || 0) + 1;
    post.likedBy.push(userId);
    await post.save();

    res.json(post);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Unlike bài viết
exports.unlikePost = async (req, res) => {
  try {
    const userId = req.body.userId;
    const post = await Post.findById(req.params.id);
    if (!post) return res.status(404).json({ message: 'Không tìm thấy bài viết' });

    // Kiểm tra xem user đã like chưa
    if (!post.likedBy.includes(userId)) {
      return res.status(400).json({ message: 'Bạn chưa like bài viết này' });
    }

    // Bỏ like
    post.likes = Math.max((post.likes || 1) - 1, 0);
    post.likedBy = post.likedBy.filter(id => id !== userId);
    await post.save();
    
    res.json(post);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Thêm bình luận mới
exports.addComment = async (req, res) => {
  const { postId } = req.params;
  const { userId, user, comment } = req.body;
  try {
    const post = await Post.findById(postId);
    if (!post) return res.status(404).json({ message: 'Post not found' });

    post.comments.push({ userId, user, comment });
    await post.save();
    res.status(201).json(post.comments);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Sửa bình luận
exports.editComment = async (req, res) => {
  const { postId, commentId } = req.params;
  const { userId, comment } = req.body;
  try {
    const post = await Post.findById(postId);
    if (!post) return res.status(404).json({ message: 'Post not found' });

    const cmt = post.comments.id(commentId);
    if (!cmt) return res.status(404).json({ message: 'Comment not found' });

    if (cmt.userId !== userId) {
      return res.status(403).json({ message: 'Bạn không có quyền sửa bình luận này' });
    }

    cmt.comment = comment;
    await post.save();
    res.json(cmt);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Xóa bình luận
exports.deleteComment = async (req, res) => {
  const { postId, commentId } = req.params;
  const { userId } = req.body;
  try {
    const post = await Post.findById(postId);
    if (!post) return res.status(404).json({ message: 'Post not found' });

    const cmt = post.comments.id(commentId);
    if (!cmt) return res.status(404).json({ message: 'Comment not found' });

    // Log sau khi đã có post và cmt
    console.log('userId:', userId);
    console.log('cmt.userId:', cmt.userId);
    console.log('post.authorId:', post.authorId);
    console.log('typeof userId:', typeof userId);
console.log('typeof cmt.userId:', typeof cmt.userId);
console.log('typeof post.authorId:', typeof post.authorId);

    // Chỉ cho phép xóa nếu là chủ comment hoặc chủ post
if (
  cmt.userId.toString() !== userId.toString() &&
  post.authorId.toString() !== userId.toString()
) {
  return res.status(403).json({ message: 'Bạn không có quyền xóa bình luận này' });
}

    post.comments = post.comments.filter(c => c._id.toString() !== commentId);
    await post.save();
    res.json({ message: 'Đã xóa bình luận' });
  } catch (err) {
  console.error('Lỗi khi xóa bình luận:', err);
  res.status(500).json({ message: err.message });
}
};

// Lấy danh sách bình luận cho một bài viết
exports.getComments = async (req, res) => {
  const post = await Post.findById(req.params.postId);
  if (!post) return res.status(404).json({ message: 'Post not found' });
  res.json(post.comments);
};

// Kiểm tra trạng thái like của user cho một bài viết
exports.checkLikeStatus = async (req, res) => {
  try {
    const { userId } = req.query;
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({ message: 'Không tìm thấy bài viết' });
    }
    
    const isLiked = post.likedBy.includes(userId);
    
    res.json({
      isLiked: isLiked,
      totalLikes: post.likes || 0,
      likedBy: post.likedBy
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};