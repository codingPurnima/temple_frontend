import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  static String? _firebaseIdToken;

  static String? get accessToken => _firebaseIdToken;

  /// Loads the currently signed-in Firebase user's token.
  ///
  /// Firebase itself manages the persistent authentication session.
  /// We don't need to manually restore a refresh token.
  Future<void> loadToken() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      _firebaseIdToken = null;
      return;
    }

    _firebaseIdToken = await user.getIdToken();
  }

  Future<String?> getRole() async {
    return await storage.read(key: "role");
  }

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return {
          "success": false,
          "error": "User not found",
        };
      }

      // Firebase may have refreshed the user's state.
      await user.reload();
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        return {
          "success": false,
          "error": "User session unavailable",
        };
      }

      if (!currentUser.emailVerified) {
        return {
          "success": false,
          "error": "Please verify your email first.",
          "email_not_verified": true,
        };
      }

      final idToken = await currentUser.getIdToken();

      if (idToken == null) {
        return {
          "success": false,
          "error": "Authentication token missing",
        };
      }

      _firebaseIdToken = idToken;

      final profileResponse = await http.get(
        Uri.parse("$baseUrl/auth/me"),
        headers: {
          "Authorization": "Bearer $idToken",
        },
      );

      if (profileResponse.statusCode != 200) {
        return {
          "success": false,
          "error": profileResponse.body,
        };
      }

      final profile = jsonDecode(profileResponse.body);

      await storage.write(
        key: "role",
        value: profile["role"],
      );

      return {
        "success": true,
        "data": profile,
      };
    } on FirebaseAuthException catch (e) {
      print("Firebase login error: ${e.code}");

      return {
        "success": false,
        "error": e.code,
      };
    } catch (e) {
      print("Login error: $e");

      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return false;
      }

      await firebaseUser.sendEmailVerification();

      final idToken = await firebaseUser.getIdToken();

      if (idToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/auth/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({
          "name": name,
        }),
      );

      if (response.statusCode == 200) {
        await _firebaseAuth.signOut();
        _firebaseIdToken = null;

        return true;
      }

      print("Profile creation failed: ${response.body}");
      return false;
    } on FirebaseAuthException catch (e) {
      print("Firebase registration error: ${e.code}");
      return false;
    } catch (e) {
      print("Registration error: $e");
      return false;
    }
  }

  /// Gets a fresh Firebase ID token.
  ///
  /// Firebase handles token refresh internally.
  /// forceRefresh = false allows Firebase to reuse a valid token.
  Future<String?> getAccessToken() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      _firebaseIdToken = null;
      return null;
    }

    final token = await user.getIdToken();

    _firebaseIdToken = token;

    return token;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();

    _firebaseIdToken = null;

    await storage.delete(key: "role");
  }

  Future<String?> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );

      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';

        default:
          return 'Unable to send the password reset email.';
      }
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }
}