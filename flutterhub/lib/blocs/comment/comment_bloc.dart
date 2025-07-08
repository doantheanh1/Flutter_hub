import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhub/blocs/comment/comment_event.dart';
import 'package:flutterhub/blocs/comment/comment_state.dart';
import 'package:flutterhub/repositories/Comment_Repository.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository repo;
  CommentBloc(this.repo) : super(CommentInitial()) {
    on<FetchComments>((event, emit) async {
      emit(CommentLoading());
      try {
        final comments = await repo.fetchComments(event.postId);
        emit(CommentLoaded(comments));
      } catch (e) {
        emit(CommentError(e.toString()));
      }
    });

    on<AddComment>((event, emit) async {
      emit(CommentLoading());
      try {
        final comments = await repo.addComment(
          event.postId,
          event.userId,
          event.user,
          event.comment,
        );
        emit(CommentLoaded(comments));
      } catch (e) {
        emit(CommentError(e.toString()));
      }
    });

    on<DeleteComment>((event, emit) async {
      emit(CommentLoading());
      try {
        await repo.deleteComment(event.postId, event.commentId, event.userId);
        final comments = await repo.fetchComments(event.postId);
        emit(CommentLoaded(comments));
      } catch (e) {
        emit(CommentError(e.toString()));
      }
    });

    on<EditComment>((event, emit) async {
      emit(CommentLoading());
      try {
        await repo.editComment(
          event.postId,
          event.commentId,
          event.userId,
          event.comment,
        );
        final comments = await repo.fetchComments(event.postId);
        emit(CommentLoaded(comments));
      } catch (e) {
        emit(CommentError(e.toString()));
      }
    });
  }
}
