const Post = require('../models/post.model');
const User = require('../models/user.model');

// Tìm kiếm user theo tên hoặc email (trừ chính mình)
const searchUsers = async (req, res) => {
  try {
    const { search = '', excludeId = '' } = req.query;
    const regex = new RegExp(search, 'i');
    const users = await User.find({
      authorId: { $ne: excludeId },
      $or: [
        { author: regex },
        { email: regex },
      ],
    }).select('author authorId avatarUrl email');
    res.json({ success: true, users });
  } catch (error) {
    console.error('Error searching users:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

// Lấy thông tin user chi tiết theo authorId hoặc email
const getUserDetail = async (req, res) => {
  try {
    const { idOrEmail } = req.params;
    let user = await Post.findOne({ authorId: idOrEmail }).select('author authorId avatarUrl email');
    if (!user) {
      user = await Post.findOne({ email: idOrEmail }).select('author authorId avatarUrl email');
    }
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, user });
  } catch (error) {
    console.error('Error getting user detail:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

// Tạo user mới hoặc trả về user đã tồn tại
const createUser = async (req, res) => {
  try {
    const { authorId, author, email, avatarUrl } = req.body;
    if (!authorId || !author || !email) {
      return res.status(400).json({ success: false, message: 'Thiếu thông tin user' });
    }
    let user = await User.findOne({ $or: [{ authorId }, { email }] });
    if (user) {
      // Cập nhật lại thông tin nếu có thay đổi
      user.author = author;
      user.email = email;
      if (avatarUrl) user.avatarUrl = avatarUrl;
      await user.save();
      return res.json({ success: true, user, existed: true, updated: true });
    }
    user = await User.create({ authorId, author, email, avatarUrl });
    res.json({ success: true, user, existed: false, updated: false });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

// Xóa user theo authorId hoặc email
const deleteUser = async (req, res) => {
  try {
    const { idOrEmail } = req.params;
    const user = await User.findOneAndDelete({
      $or: [
        { authorId: idOrEmail },
        { email: idOrEmail }
      ]
    });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, message: 'User deleted', user });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

// Thống kê bài viết, like, comment của user
const getUserStats = async (req, res) => {
  try {
    const { userId } = req.params;
    const posts = await Post.find({ authorId: userId });
    const postsCount = posts.length;
    const likesCount = posts.reduce((sum, post) => sum + (post.likes || 0), 0);
    const commentsCount = posts.reduce((sum, post) => sum + (post.comments ? post.comments.length : 0), 0);

    res.json({
      success: true,
      stats: {
        posts: postsCount,
        likes: likesCount,
        comments: commentsCount
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

module.exports = { searchUsers, getUserDetail, createUser, deleteUser, getUserStats }; 