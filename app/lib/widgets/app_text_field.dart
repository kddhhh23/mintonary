import 'package:flutter/material.dart';

/// 로그인·회원가입에서 함께 쓰는 입력 필드
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
  });

  /// 입력 전에 보여줄 안내 문구
  final String hint;

  /// 입력값을 읽어오는 컨트롤러
  final TextEditingController controller;

  /// true면 비밀번호처럼 입력값을 가림
  final bool obscure;

  /// 이메일처럼 전용 키보드가 필요할 때 지정
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA8B0BF)),
        filled: true, // 배경색 채우기 활성화
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
