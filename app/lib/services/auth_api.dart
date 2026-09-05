import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class LoginResult {
  const LoginResult({required this.accessToken, required this.nickname});

  final String accessToken;
  final String nickname;
}

/// 로그인·회원가입 API 호출
class AuthApi {
  /// 안드로이드 에뮬레이터는 10.0.2.2가 PC의 localhost를 가리킨다
  static String get _baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static const _jsonHeader = {'Content-Type': 'application/json'};

  /// 성공하면 액세스 토큰과 닉네임, 실패하면 서버가 준 메시지로 예외를 던진다
  static Future<LoginResult> login(String loginId, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: _jsonHeader,
      body: jsonEncode({'loginId': loginId, 'password': password}),
    );

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return LoginResult(
        accessToken: body['accessToken'] as String,
        nickname: body['nickname'] as String,
      );
    }
    throw Exception(body['message'] ?? '로그인에 실패했습니다.');
  }

  /// null인 선택 항목은 서버로 보내지 않는다
  static Future<void> signup({
    required String loginId,
    required String password,
    required String nickname,
    String? email,
    String? birthDate,
    String? gender,
    String? localClass,
    String? nationalClass,
  }) async {
    final payload = {
      'loginId': loginId,
      'password': password,
      'nickname': nickname,
      if (email != null && email.isNotEmpty) 'email': email,
      'birthDate': ?birthDate,
      'gender': ?gender,
      'localClass': ?localClass,
      'nationalClass': ?nationalClass,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/api/members/signup'),
      headers: _jsonHeader,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) return;

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception(body['message'] ?? '회원가입에 실패했습니다.');
  }
}
