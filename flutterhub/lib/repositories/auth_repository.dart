import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/google_auth_service.dart';

class AuthRepository {
  final GoogleAuthService _googleAuthService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthRepository(this._googleAuthService);

  Future<dynamic> signInWithGoogle() async {
    return await _googleAuthService.signInWithGoogle();
  }

  Future<User> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(name);
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Email này đã được đăng ký');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ');
      } else if (e.code == 'weak-password') {
        throw Exception('Mật khẩu quá yếu');
      } else {
        throw Exception('Lỗi đăng ký: ${e.message}');
      }
    }
  }

  Future<User> signInWithEmail(String email, String password) async {
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user!;
  }

  Future<void> signOut() async {
    await _googleAuthService.signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<User> updateProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    User? user = _firebaseAuth.currentUser;

    if (user == null) throw Exception("User chưa đăng nhập");

    await user.updateDisplayName(displayName);

    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    await user.reload(); // refresh user data
    return _firebaseAuth.currentUser!;
  }

  Future<void> createUserOnBackend({
    required String authorId,
    required String author,
    required String email,
    String? avatarUrl,
  }) async {
    final url = Uri.parse('http://10.0.2.2:3000/api/users');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'authorId': authorId,
        'author': author,
        'email': email,
        'avatarUrl': avatarUrl,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi tạo user backend: \\${response.body}');
    }
  }
}
