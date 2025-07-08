class Comment {
  final String id;
  final String userId;
  final String user;
  final String comment;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.user,
    required this.comment,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['_id'],
    userId: json['userId'],
    user: json['user'],
    comment: json['comment'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
