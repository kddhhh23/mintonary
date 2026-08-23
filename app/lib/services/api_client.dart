import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'session.dart';

/// 서버 주소와 공통 헤더
class ApiClient {
  ApiClient._();

  /// 안드로이드 에뮬레이터는 10.0.2.2가 PC의 localhost를 가리킨다
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  /// JSON 요청 + 로그인 토큰 헤더
  static Map<String, String> get authJsonHeaders => {
    'Content-Type': 'application/json',
    if (Session.accessToken != null)
      'Authorization': 'Bearer ${Session.accessToken}',
  };
}
