import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// 로그인·회원가입 API 호출
class AuthApi {
  /// 안드로이드 에뮬레이터는 10.0.2.2가 PC의 localhost를 가리킨다
  static String get _baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  /// 성공하면 액세스 토큰, 실패하면 서버가 준 메시지로 예외를 던진다
  static Future<String> login(String loginId, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'loginId': loginId, 'password': password}),
    );

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return body['accessToken'] as String;
    }
    throw Exception(body['message'] ?? '로그인에 실패했습니다.');
  }
}
