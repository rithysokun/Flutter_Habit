import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SignedInUser {
  const SignedInUser({required this.name, required this.email});

  final String name;
  final String email;
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthApi {
  /// The Android emulator reaches this Mac as 10.0.2.2, not 127.0.0.1.
  static final String base = !kIsWeb && Platform.isAndroid
      ? 'http://10.0.2.2:8787'
      : 'http://127.0.0.1:8787';

  Future<SignedInUser> signIn({
    required String email,
    required String password,
  }) {
    return _post(
      '/sign-in',
      {'email': email.trim(), 'password': password},
      okStatus: 200,
      fallbackEmail: email.trim(),
      fallbackMessage: 'Sign-in failed.',
    );
  }

  Future<SignedInUser> createAccount({
    required String name,
    required String email,
    required String password,
  }) {
    return _post(
      '/create-account',
      {'name': name.trim(), 'email': email.trim(), 'password': password},
      okStatus: 201,
      fallbackEmail: email.trim(),
      fallbackMessage: 'Could not create the account.',
    );
  }

  Future<SignedInUser> updateName({
    required String email,
    required String name,
  }) {
    return _post(
      '/update-name',
      {'email': email.trim(), 'name': name.trim()},
      okStatus: 200,
      fallbackEmail: email.trim(),
      fallbackMessage: 'Could not update your name.',
    );
  }

  Future<SignedInUser> _post(
    String path,
    Map<String, String> body, {
    required int okStatus,
    required String fallbackEmail,
    required String fallbackMessage,
  }) async {
    final http.Response response;
    try {
      response = await http.post(
        Uri.parse('$base$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const AuthApiException(
        'Cannot reach the account service. Start it with: server/.venv/bin/python server/sign_in_api.py',
      );
    }

    final decoded = _readBody(response);
    if (response.statusCode == okStatus) {
      return SignedInUser(
        name: decoded['name']?.toString() ?? body['name'] ?? '',
        email: decoded['email']?.toString() ?? fallbackEmail,
      );
    }

    throw AuthApiException(decoded['message']?.toString() ?? fallbackMessage);
  }

  Map<String, dynamic> _readBody(http.Response response) {
    if (response.body.isEmpty) return {};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {};
  }
}
