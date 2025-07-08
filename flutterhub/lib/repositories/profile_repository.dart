import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileStats {
  final int posts;
  final int likes;
  final int comments;

  ProfileStats({
    required this.posts,
    required this.likes,
    required this.comments,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      posts: json['posts'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
    );
  }
}

class ProfileRepository {
  final String baseUrl;
  ProfileRepository({
    this.baseUrl = 'http://10.0.2.2:3000/api/users',
  }); // Sửa baseUrl nếu cần

  Future<ProfileStats> getProfileStats(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId/stats'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['stats'] != null) {
        return ProfileStats.fromJson(data['stats']);
      } else {
        throw Exception('Lỗi lấy thống kê');
      }
    } else {
      throw Exception('Lỗi kết nối API');
    }
  }
}
