/// 로그인 세션 — 앱이 실행되는 동안 토큰을 들고 있는다
class Session {
  Session._();

  /// 로그인 성공 시 받은 액세스 토큰. 앱을 재실행하면 사라진다
  // TODO: flutter_secure_storage로 저장해 앱 재실행 후에도 로그인 유지
  static String? accessToken;

  /// 로그인 응답으로 받은 사용자 닉네임
  static String? nickname;
}
