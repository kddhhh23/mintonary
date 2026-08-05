import 'package:flutter/material.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);

/// 로그인 화면
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28), // 좌우 여백
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100), // 상단 여백

              // 앱 로고
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    'assets/mintonary_icon.png',
                    width: 96,
                    height: 96,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 앱 이름
              const Text(
                '민터너리',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 10),

              // 부제목
              const Text(
                '나의 배드민턴 다이어리',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: _gray),
              ),

              const SizedBox(height: 48),

              // 아이디 입력
              const _InputField(hint: '아이디'),

              const SizedBox(height: 14),

              // 비밀번호 입력 (obscure: 입력값을 ●로 가림)
              const _InputField(hint: '비밀번호', obscure: true),

              const SizedBox(height: 20),
              
              // 로그인 버튼
              FilledButton(
                onPressed: () {}, // TODO: 로그인 처리
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  minimumSize: const Size.fromHeight(58), // 가로 꽉 채우고 높이 58
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 20),

              // 아이디 찾기 | 비밀번호 찾기 | 회원가입
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {}, // TODO: 아이디 찾기 화면 이동
                    child: const Text('아이디 찾기', style: TextStyle(color: _gray)),
                  ),
                  const Text('|', style: TextStyle(color: _gray)),
                  TextButton(
                    onPressed: () {}, // TODO: 비밀번호 찾기 화면 이동
                    child: const Text(
                      '비밀번호 찾기',
                      style: TextStyle(color: _gray),
                    ),
                  ),
                  const Text('|', style: TextStyle(color: _gray)),
                  TextButton(
                    onPressed: () {}, // TODO: 회원가입 화면 이동
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 아이디, 비밀번호 공용 입력 필드
class _InputField extends StatelessWidget {
  const _InputField({required this.hint, this.obscure = false});

  /// 입력 전에 보여줄 안내 문구
  final String hint;

  /// true면 비밀번호처럼 입력값을 가림
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA8B0BF)),
        filled: true,
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
