const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  authorId: { type: String, required: true, unique: true }, // uid Firebase
  author: { type: String, required: true }, // displayName
  email: { type: String, required: true, unique: true },
  avatarUrl: { type: String },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', userSchema); 