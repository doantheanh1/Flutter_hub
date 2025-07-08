const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chat.controller');

// Get all conversations for a user
router.get('/conversations/:userId', chatController.getConversations);

// Get messages for a specific conversation
router.get('/messages/:conversationId', chatController.getMessages);

// Send a message
router.post('/send', chatController.sendMessage);

// Mark messages as read
router.put('/read/:conversationId/:userId', chatController.markAsRead);

// Delete a message
router.delete('/message/:messageId/:userId', chatController.deleteMessage);

module.exports = router; 