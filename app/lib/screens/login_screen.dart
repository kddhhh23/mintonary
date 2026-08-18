import 'package:flutter/material.dart';

import '../services/auth_api.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

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
      // TODO: 토큰 저장
      _showMessage('로그인 성공 (토큰 ${token.length}자)');
      // 홈으로 이동 — pushReplacement: 로그인 화면을 스택에서 빼서 뒤로가기로 못 돌아오게 함
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 가입에 성공하면 true를 들고 돌아온다
  Future<void> _openSignup() async {
    final signedUp = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
    if (signedUp == true && mounted) {
      _showMessage('회원가입이 완료되었습니다. 로그인해 주세요.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
              AppTextField(hint: '아이디', controller: _idController),

              const SizedBox(height: 14),

              // 비밀번호 입력 (obscure: 입력값을 ●로 가림)
              AppTextField(
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
                    onPressed: _openSignup,
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
