const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, required: true },
  author: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  imageUrls: [{ type: String, required: true }], 
  likes: { type: Number, default: 0 },
  avatarUrl: { type: String, required: true },
  likedBy: [{ type: String }],
  authorId: { type: String, required: true },
  comments: [
    {
      userId: String,
      user: String,
      comment: String,
      createdAt: { type: Date, default: Date.now }
    }
  ]
});

module.exports = mongoose.model('Post', postSchema);