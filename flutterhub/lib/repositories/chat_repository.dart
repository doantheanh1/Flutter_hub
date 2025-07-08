import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatRepository {
  static const String baseUrl = 'http://10.0.2.2:3000/api/chat';

  // Get all conversations for a user
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['conversations']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load conversations');
        }
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get messages for a conversation
  Future<List<Map<String, dynamic>>> getMessages(
    String conversationId,
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$conversationId?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['messages']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load messages');
        }
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Send a message
  Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
          'messageType': messageType,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['message'];
        } else {
          throw Exception(data['message'] ?? 'Failed to send message');
        }
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/read/$conversationId/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to mark messages as read');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/message/$messageId/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete message');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
