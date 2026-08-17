import 'package:flutter/material.dart';

import '../services/auth_api.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);

/// 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  /// 요청 중이면 true — 버튼을 잠가 중복 요청을 막는다
  bool _loading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final token = await AuthApi.login(
        _idController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      // TODO: 토큰 저장 후 홈 화면으로 이동
      _showMessage('로그인 성공 (토큰 ${token.length}자)');
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

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
              _InputField(hint: '아이디', controller: _idController),

              const SizedBox(height: 14),

              // 비밀번호 입력 (obscure: 입력값을 ●로 가림)
              _InputField(
                hint: '비밀번호',
                controller: _passwordController,
                obscure: true,
              ),

              const SizedBox(height: 20),

              // 로그인 버튼
              FilledButton(
                onPressed: _loading ? null : _login,
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  minimumSize: const Size.fromHeight(58), // 가로 꽉 채우고 높이 58
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
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
  const _InputField({
    required this.hint,
    required this.controller,
    this.obscure = false,
  });

  /// 입력 전에 보여줄 안내 문구
  final String hint;

  /// 입력값을 읽어오는 컨트롤러
  final TextEditingController controller;

  /// true면 비밀번호처럼 입력값을 가림
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
