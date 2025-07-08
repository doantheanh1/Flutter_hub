import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final String apiBaseUrl =
      'http://10.0.2.2:3000/api/posts'; // dùng cho Android emulator

  PostBloc() : super(PostInitial()) {
    on<CreatePostEvent>((event, emit) async {
      emit(PostLoading());
      try {
        var request = http.MultipartRequest('POST', Uri.parse(apiBaseUrl));

        request.fields['title'] = event.title;
        request.fields['content'] = event.content;
        request.fields['author'] = event.author;
        request.fields['avatarUrl'] = event.avatarUrl;
        request.fields['authorId'] = event.authorId;

        // Gửi nhiều ảnh với tên trường 'images'
        if (event.imageFiles.isNotEmpty) {
          for (var file in event.imageFiles) {
            var multipartFile = await http.MultipartFile.fromPath(
              'images', // phải trùng với backend
              file.path,
            );
            request.files.add(multipartFile);
          }
        } else {
          emit(PostError('Vui lòng chọn ít nhất một ảnh để tạo bài viết'));
          return;
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201 || response.statusCode == 200) {
          emit(PostCreatedSuccess());
          final getResponse = await http.get(Uri.parse(apiBaseUrl));
          if (getResponse.statusCode == 200) {
            final data = jsonDecode(getResponse.body);
            emit(PostLoaded(data));
          } else {
            emit(PostError('Lấy lại danh sách bài viết thất bại'));
          }
        } else {
          emit(PostError('Tạo bài viết thất bại: ${response.body}'));
        }
      } catch (e) {
        emit(PostError('Lỗi: $e'));
      }
    });
    on<FetchPostsEvent>((event, emit) async {
      emit(PostLoading());
      try {
        final response = await http.get(Uri.parse(apiBaseUrl));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          emit(PostLoaded(data));
        } else {
          emit(PostError('Lấy danh sách bài viết thất bại'));
        }
      } catch (e) {
        emit(PostError('Lỗi khi lấy bài viết: $e'));
      }
    });
  }
}
