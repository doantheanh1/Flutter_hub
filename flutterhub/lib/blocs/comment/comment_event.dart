abstract class CommentEvent {}

class FetchComments extends CommentEvent {
  final String postId;
  FetchComments(this.postId);
}

class AddComment extends CommentEvent {
  final String postId, userId, user, comment;
  AddComment(this.postId, this.userId, this.user, this.comment);
}

class DeleteComment extends CommentEvent {
  final String postId, commentId, userId;
  DeleteComment(this.postId, this.commentId, this.userId);
}

class EditComment extends CommentEvent {
  final String postId, commentId, userId, comment;
  EditComment(this.postId, this.commentId, this.userId, this.comment);
}
