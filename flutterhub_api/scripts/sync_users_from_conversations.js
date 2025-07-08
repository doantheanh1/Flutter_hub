const mongoose = require('mongoose');
const Conversation = require('../models/chat.model').Conversation;
const User = require('../models/user.model');

const MONGO_URI = 'mongodb://localhost:27017/flutterhub';

async function syncUsers() {
  await mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
  console.log('Connected to MongoDB');

  const conversations = await Conversation.find({});
  const allUserIds = new Set();
  conversations.forEach(conv => {
    conv.participants.forEach(id => allUserIds.add(id));
  });

  let created = 0;
  for (const authorId of allUserIds) {
    const existed = await User.findOne({ authorId });
    if (!existed) {
      await User.create({
        authorId,
        author: 'User_' + authorId.slice(-5),
        email: authorId + '@unknown.local',
        avatarUrl: '',
      });
      console.log('Created user:', authorId);
      created++;
    }
  }
  console.log(`Đã đồng bộ xong. Đã tạo mới ${created} user.`);
  process.exit(0);
}

syncUsers().catch(err => {
  console.error('Lỗi:', err);
  process.exit(1);
}); 