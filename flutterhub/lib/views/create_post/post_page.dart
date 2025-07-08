import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhub/blocs/post/post_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutterhub/blocs/post/post_bloc.dart';
import 'package:flutterhub/blocs/post/post_event.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  List<File> _imageFiles = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  void _submitPost() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Vui lòng nhập đầy đủ tiêu đề và nội dung')),
            ],
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.image_not_supported, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Vui lòng chọn ít nhất một ảnh')),
            ],
          ),
          backgroundColor: Colors.orange[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    final avatarUrl = user?.photoURL ?? '';

    context.read<PostBloc>().add(
      CreatePostEvent(
        title: title,
        content: content,
        author: user?.displayName ?? 'Admin',
        authorId: user?.uid ?? '',
        imageFiles: _imageFiles,
        avatarUrl: avatarUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostCreatedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.onPrimary),
                  SizedBox(width: 8),
                  Text('Bài viết đã được đăng thành công!'),
                ],
              ),
              backgroundColor: theme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          }
        } else if (state is PostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.onError),
                  SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  theme.brightness == Brightness.dark
                      ? [
                        theme.colorScheme.background,
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withOpacity(0.8),
                      ]
                      : [
                        Colors.blue[50]!,
                        Colors.purple[50]!,
                        Colors.pink[50]!,
                      ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.95),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Tạo bài viết mới',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Spacer(),
                      if (_isSubmitting)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Đang đăng...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Input
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _titleController,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Tiêu đề bài viết...',
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                                fontSize: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: EdgeInsets.all(20),
                              prefixIcon: Icon(
                                Icons.title,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Content Input
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _contentController,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: 'Viết nội dung bài viết của bạn...',
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: EdgeInsets.all(20),
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Image Picker Section
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.photo_library,
                                      color: theme.colorScheme.secondary,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Hình ảnh',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      '${_imageFiles.length}/10',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Image Picker Button
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: GestureDetector(
                                  onTap:
                                      _imageFiles.length < 10
                                          ? _pickImages
                                          : null,
                                  child: Container(
                                    width: double.infinity,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color:
                                          _imageFiles.length < 10
                                              ? theme.colorScheme.secondary
                                                  .withOpacity(0.08)
                                              : theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            _imageFiles.length < 10
                                                ? theme.colorScheme.secondary
                                                    .withOpacity(0.3)
                                                : theme.colorScheme.outline
                                                    .withOpacity(0.2),
                                        width: 2,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 40,
                                          color:
                                              _imageFiles.length < 10
                                                  ? theme.colorScheme.secondary
                                                  : theme.colorScheme.onSurface
                                                      .withOpacity(0.3),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          _imageFiles.length < 10
                                              ? 'Thêm hình ảnh'
                                              : 'Đã đạt giới hạn',
                                          style: TextStyle(
                                            color:
                                                _imageFiles.length < 10
                                                    ? theme
                                                        .colorScheme
                                                        .secondary
                                                    : theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.5),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (_imageFiles.length < 10)
                                          Text(
                                            'Tối đa 10 ảnh',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Selected Images
                              if (_imageFiles.isNotEmpty) ...[
                                SizedBox(height: 16),
                                Container(
                                  height: 120,
                                  child: ListView.separated(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _imageFiles.length,
                                    separatorBuilder:
                                        (_, __) => SizedBox(width: 12),
                                    itemBuilder:
                                        (context, index) => Stack(
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: theme.shadowColor
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.file(
                                                  _imageFiles[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _imageFiles.removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        theme.colorScheme.error,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: theme.shadowColor
                                                            .withOpacity(0.2),
                                                        blurRadius: 4,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .onError,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  ),
                                ),
                              ],

                              SizedBox(height: 20),
                            ],
                          ),
                        ),

                        SizedBox(height: 32),

                        // Submit Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isSubmitting ? null : _submitPost,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isSubmitting) ...[
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                theme.colorScheme.onPrimary,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                    ] else ...[
                                      Icon(
                                        Icons.send_rounded,
                                        color: theme.colorScheme.onPrimary,
                                        size: 24,
                                      ),
                                      SizedBox(width: 12),
                                    ],
                                    Text(
                                      _isSubmitting
                                          ? 'Đang đăng bài...'
                                          : 'Đăng bài viết',
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
