import 'package:flutterhub/models/comment_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommentRepository {
  final String baseUrl;

  CommentRepository(this.baseUrl);

  Future<List<Comment>> fetchComments(String postId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/posts/$postId/comments'),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      // Nếu backend trả về mảng bình luận:
      return (data as List).map((e) => Comment.fromJson(e)).toList();
      // Nếu backend trả về {comments: [...]}, dùng:
      // return (data['comments'] as List).map((e) => Comment.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi: ${res.body}');
    }
  }

  Future<List<Comment>> addComment(
    String postId,
    String userId,
    String user,
    String comment,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/posts/$postId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId, 'user': user, 'comment': comment}),
    );
    final data = json.decode(res.body);
    return (data as List).map((e) => Comment.fromJson(e)).toList();
  }

  Future<void> deleteComment(
    String postId,
    String commentId,
    String userId,
  ) async {
    await http.delete(
      Uri.parse('$baseUrl/api/posts/$postId/comments/$commentId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId}),
    );
  }

  Future<void> editComment(
    String postId,
    String commentId,
    String userId,
    String comment,
  ) async {
    await http.put(
      Uri.parse('$baseUrl/api/posts/$postId/comments/$commentId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId, 'comment': comment}),
    );
  }
}
