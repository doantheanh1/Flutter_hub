import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPostsEvent extends PostEvent {}

class CreatePostEvent extends PostEvent {
  final String title;
  final String content;
  final String author;
  final String authorId; // <-- Thêm dòng này
  final List<File> imageFiles;
  final String avatarUrl;

  CreatePostEvent({
    required this.title,
    required this.content,
    required this.author,
    required this.authorId, // <-- Thêm dòng này
    required this.imageFiles,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [title, content, author, imageFiles, avatarUrl];
}
