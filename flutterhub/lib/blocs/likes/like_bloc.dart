import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'like_event.dart';
import 'like_state.dart';

class LikeBloc extends Bloc<LikeEvent, LikeState> {
  final String apiBaseUrl = 'http://10.0.2.2:3000/api/posts';

  LikeBloc() : super(LikeInitial()) {
    // Thả tym
    on<LikePostEvent>((event, emit) async {
      emit(LikeLoading());
      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/${event.postId}/like'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': event.userId}),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          emit(LikeSuccess(postData: responseData));
        } else if (response.statusCode == 400) {
          final errorData = jsonDecode(response.body);
          emit(LikeError(errorData['message'] ?? 'Like thất bại'));
        } else {
          emit(LikeError('Like thất bại: ${response.statusCode}'));
        }
      } catch (e) {
        emit(LikeError('Lỗi kết nối: $e'));
      }
    });

    // Bỏ tym
    on<UnlikePostEvent>((event, emit) async {
      emit(LikeLoading());
      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/${event.postId}/unlike'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': event.userId}),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          emit(LikeSuccess(postData: responseData));
        } else if (response.statusCode == 400) {
          final errorData = jsonDecode(response.body);
          emit(LikeError(errorData['message'] ?? 'Unlike thất bại'));
        } else {
          emit(LikeError('Unlike thất bại: ${response.statusCode}'));
        }
      } catch (e) {
        emit(LikeError('Lỗi kết nối: $e'));
      }
    });

    // Kiểm tra trạng thái like
    on<CheckLikeStatusEvent>((event, emit) async {
      emit(LikeLoading());
      try {
        final response = await http.get(
          Uri.parse(
            '$apiBaseUrl/${event.postId}/like-status?userId=${event.userId}',
          ),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          emit(
            LikeStatusLoaded(
              isLiked: responseData['isLiked'] ?? false,
              totalLikes: responseData['totalLikes'] ?? 0,
              likedBy: List<String>.from(responseData['likedBy'] ?? []),
            ),
          );
        } else {
          emit(LikeError('Không thể kiểm tra trạng thái like'));
        }
      } catch (e) {
        emit(LikeError('Lỗi kết nối: $e'));
      }
    });
  }
}
