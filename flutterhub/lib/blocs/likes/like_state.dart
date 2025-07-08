// TODO Implement this library.
abstract class LikeState {}

class LikeInitial extends LikeState {}

class LikeLoading extends LikeState {}

class LikeSuccess extends LikeState {
  final Map<String, dynamic>? postData;
  LikeSuccess({this.postData});
}

class LikeError extends LikeState {
  final String message;
  LikeError(this.message);
}

class LikeStatusLoaded extends LikeState {
  final bool isLiked;
  final int totalLikes;
  final List<String> likedBy;
  LikeStatusLoaded({
    required this.isLiked,
    required this.totalLikes,
    required this.likedBy,
  });
}
