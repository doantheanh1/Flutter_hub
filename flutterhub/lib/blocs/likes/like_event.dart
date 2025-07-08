abstract class LikeEvent {}

class LikePostEvent extends LikeEvent {
  final String postId;
  final String userId;
  LikePostEvent(this.postId, this.userId);
}

class UnlikePostEvent extends LikeEvent {
  final String postId;
  final String userId;
  UnlikePostEvent(this.postId, this.userId);
}

class CheckLikeStatusEvent extends LikeEvent {
  final String postId;
  final String userId;
  CheckLikeStatusEvent(this.postId, this.userId);
}
