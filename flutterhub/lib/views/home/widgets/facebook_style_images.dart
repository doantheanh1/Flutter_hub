// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FacebookStyleImages extends StatelessWidget {
  final List<dynamic> imageUrls;
  const FacebookStyleImages({super.key, required this.imageUrls});

  String _fullUrl(dynamic url) {
    final u = url.toString();
    return u.startsWith('http') ? u : 'http://10.0.2.2:3000$u';
  }

  void _openGallery(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  PhotoViewGallery.builder(
                    itemCount: imageUrls.length,
                    builder:
                        (ctx, idx) => PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(_fullUrl(imageUrls[idx])),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                        ),
                    pageController: PageController(initialPage: initialIndex),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = imageUrls.length;
    if (count == 1) {
      return GestureDetector(
        onTap: () => _openGallery(context, 0),
        child: Image.network(
          _fullUrl(imageUrls[0]),
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
      );
    }
    if (count == 2) {
      return Row(
        children: List.generate(2, (i) {
          return Expanded(
            child: GestureDetector(
              onTap: () => _openGallery(context, i),
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 1 ? 4 : 0,
                  right: i == 0 ? 4 : 0,
                ),
                child: Image.network(
                  _fullUrl(imageUrls[i]),
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      );
    }
    if (count == 3) {
      return SizedBox(
        height: 220,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => _openGallery(context, 0),
                child: Image.network(
                  _fullUrl(imageUrls[0]),
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 1,
              child: Column(
                children: List.generate(2, (i) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _openGallery(context, i + 1),
                      child: Padding(
                        padding: EdgeInsets.only(top: i == 1 ? 4 : 0),
                        child: Image.network(
                          _fullUrl(imageUrls[i + 1]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    }
    // 4 ảnh hoặc nhiều hơn: 1 lớn bên trái, 3 nhỏ dọc bên phải, có khoảng cách đều
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          // Ảnh lớn bên trái
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _openGallery(context, 0),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Image.network(
                  _fullUrl(imageUrls[0]),
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // 3 ảnh nhỏ dọc bên phải
          Expanded(
            flex: 1,
            child: Column(
              children: List.generate(3, (i) {
                final imgIdx = i + 1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _openGallery(context, imgIdx),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i < 2 ? 4 : 0),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            _fullUrl(imageUrls[imgIdx]),
                            fit: BoxFit.cover,
                          ),
                          // Nếu là ảnh cuối và còn nhiều ảnh hơn
                          if (imgIdx == 3 && count > 4)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Center(
                                child: Text(
                                  '+${count - 4}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
