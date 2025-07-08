const { Message, Conversation } = require('../models/chat.model');
const User = require('../models/user.model');

// Get all conversations for a user
const getConversations = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const conversations = await Conversation.find({
      participants: userId
    })
    .populate('lastMessage')
    .sort({ lastMessageTime: -1 });

    // Get user info for each conversation
    const conversationsWithUserInfo = await Promise.all(
      conversations.map(async (conv) => {
        const otherParticipantId = conv.participants.find(id => id !== userId);
        
        // Get user info from your user model (adjust as needed)
        const otherUser = await User.findOne({
          authorId: otherParticipantId
        }).select('author avatarUrl');

        return {
          _id: conv._id,
          lastMessage: conv.lastMessage,
          lastMessageContent: conv.lastMessageContent,
          lastMessageTime: conv.lastMessageTime,
          unreadCount: conv.unreadCount[userId] || 0,
          otherUser: {
            id: otherParticipantId,
            name: otherUser?.author || 'Unknown User',
            avatar: otherUser?.avatarUrl || null
          }
        };
      })
    );

    res.json({
      success: true,
      conversations: conversationsWithUserInfo
    });
  } catch (error) {
    console.error('Error getting conversations:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Get messages for a specific conversation
const getMessages = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { userId } = req.query;

    // Find conversation
    const conversation = await Conversation.findById(conversationId);
    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }

    // Check if user is participant
    if (!conversation.participants.includes(userId)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Get messages
    const messages = await Message.find({
      $or: [
        { senderId: userId, receiverId: { $in: conversation.participants.filter(id => id !== userId) } },
        { senderId: { $in: conversation.participants.filter(id => id !== userId) }, receiverId: userId }
      ]
    }).sort({ createdAt: 1 });

    // Mark messages as read
    await Message.updateMany(
      {
        senderId: { $in: conversation.participants.filter(id => id !== userId) },
        receiverId: userId,
        isRead: false
      },
      {
        isRead: true,
        readAt: new Date()
      }
    );

    // Update unread count
    await Conversation.findByIdAndUpdate(conversationId, {
      $set: { [`unreadCount.${userId}`]: 0 }
    });

    res.json({
      success: true,
      messages
    });
  } catch (error) {
    console.error('Error getting messages:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Send a message
const sendMessage = async (req, res) => {
  try {
    const { senderId, receiverId, content, messageType = 'text' } = req.body;

    if (!senderId || !receiverId || !content) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    // Create or find conversation
    let conversation = await Conversation.findOne({
      participants: { $all: [senderId, receiverId] }
    });

    if (!conversation) {
      conversation = new Conversation({
        participants: [senderId, receiverId],
        unreadCount: { [receiverId]: 0 }
      });
    }

    // Create message
    const message = new Message({
      senderId,
      receiverId,
      content,
      messageType
    });

    await message.save();

    // Update conversation
    conversation.lastMessage = message._id;
    conversation.lastMessageContent = content;
    conversation.lastMessageTime = new Date();
    conversation.unreadCount.set(receiverId, (conversation.unreadCount.get(receiverId) || 0) + 1);
    await conversation.save();

    // Populate sender info
    const populatedMessage = await Message.findById(message._id);
    const senderInfo = await User.findOne({
      authorId: senderId
    }).select('author avatarUrl');

    const messageWithSender = {
      ...populatedMessage.toObject(),
      senderInfo: {
        name: senderInfo?.author || 'Unknown User',
        avatar: senderInfo?.avatarUrl || null
      },
      conversationId: conversation._id
    };

    res.json({
      success: true,
      message: messageWithSender,
      conversationId: conversation._id
    });
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Mark messages as read
const markAsRead = async (req, res) => {
  try {
    const { conversationId, userId } = req.params;

    const conversation = await Conversation.findById(conversationId);
    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }

    // Mark messages as read
    await Message.updateMany(
      {
        senderId: { $in: conversation.participants.filter(id => id !== userId) },
        receiverId: userId,
        isRead: false
      },
      {
        isRead: true,
        readAt: new Date()
      }
    );

    // Reset unread count
    conversation.unreadCount.set(userId, 0);
    await conversation.save();

    res.json({
      success: true,
      message: 'Messages marked as read'
    });
  } catch (error) {
    console.error('Error marking messages as read:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Delete message
const deleteMessage = async (req, res) => {
  try {
    const { messageId, userId } = req.params;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    // Check if user is the sender
    if (message.senderId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Can only delete your own messages'
      });
    }

    await Message.findByIdAndDelete(messageId);

    res.json({
      success: true,
      message: 'Message deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting message:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

module.exports = {
  getConversations,
  getMessages,
  sendMessage,
  markAsRead,
  deleteMessage
}; 