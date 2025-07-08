import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryRepository {
  final String cloudName = 'dlyljxshn';
  final String uploadPreset = 'TheAnh_upload';

  Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/dlyljxshn/image/upload',
    );
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await request.send();
    final resStream = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = json.decode(resStream.body);
      return data['secure_url'];
    } else {
      throw Exception('Upload failed: ${resStream.body}');
    }
  }
}
