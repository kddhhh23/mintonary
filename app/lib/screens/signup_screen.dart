import 'package:flutter/material.dart';

import '../services/auth_api.dart';
import '../widgets/app_text_field.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);

/// 급수 코드와 화면에 보여줄 이름
const _classOptions = {
  'S': '자강',
  'A': 'A조',
  'B': 'B조',
  'C': 'C조',
  'D': 'D조',
  'E': 'E조',
  'F': 'F조',
};

/// 회원가입 화면
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();

  // 선택 입력 — 고르지 않으면 null로 두고 서버에 보내지 않는다
  DateTime? _birthDate;
  String? _gender;
  String? _localClass;
  String? _nationalClass;

  bool _loading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// 서버가 받는 형식(2000-01-01)으로 변환
  String _toIsoDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1930),
      lastDate: now,
      helpText: '생년월일 선택',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _signup() async {
    // 비밀번호 확인은 서버로 보내지 않으므로 앱에서 먼저 검사한다
    if (_passwordController.text != _passwordConfirmController.text) {
      _showMessage('비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthApi.signup(
        loginId: _idController.text.trim(),
        password: _passwordController.text,
        nickname: _nicknameController.text.trim(),
        email: _emailController.text.trim(),
        birthDate: _birthDate == null ? null : _toIsoDate(_birthDate!),
        gender: _gender,
        localClass: _localClass,
        nationalClass: _nationalClass,
      );
      if (!mounted) return;
      Navigator.pop(context, true); // 로그인 화면으로 돌아가며 성공을 알림
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
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
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionLabel('필수 정보'),

              AppTextField(hint: '아이디 (4~30자)', controller: _idController),
              const SizedBox(height: 14),

              AppTextField(
                hint: '비밀번호 (8~20자)',
                controller: _passwordController,
                obscure: true,
              ),
              const SizedBox(height: 14),

              AppTextField(
                hint: '비밀번호 확인',
                controller: _passwordConfirmController,
                obscure: true,
              ),
              const SizedBox(height: 14),

              AppTextField(hint: '닉네임', controller: _nicknameController),

              const SizedBox(height: 32),
              const _SectionLabel('선택 정보'),

              AppTextField(
                hint: '이메일',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // 생년월일 — 달력에서 고른다
              _PickerBox(
                label: _birthDate == null ? '생년월일' : _toIsoDate(_birthDate!),
                selected: _birthDate != null,
                onTap: _pickBirthDate,
              ),
              const SizedBox(height: 14),

              // 성별 — 한 번 더 누르면 선택 해제
              Row(
                children: [
                  Expanded(
                    child: _ChoiceButton(
                      label: '남자',
                      selected: _gender == 'MALE',
                      onTap: () => setState(
                        () => _gender = _gender == 'MALE' ? null : 'MALE',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ChoiceButton(
                      label: '여자',
                      selected: _gender == 'FEMALE',
                      onTap: () => setState(
                        () => _gender = _gender == 'FEMALE' ? null : 'FEMALE',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _ClassDropdown(
                label: '지역 대회 급수',
                value: _localClass,
                onChanged: (value) => setState(() => _localClass = value),
              ),
              const SizedBox(height: 14),

              _ClassDropdown(
                label: '전국 대회 급수',
                value: _nationalClass,
                onChanged: (value) => setState(() => _nationalClass = value),
              ),

              const SizedBox(height: 32),

              FilledButton(
                onPressed: _loading ? null : _signup,
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  minimumSize: const Size.fromHeight(58),
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
                        '가입하기',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 입력 묶음 위에 붙는 제목
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// 탭하면 달력이 열리는 입력칸 모양 박스
class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: selected ? Colors.black87 : const Color(0xFFA8B0BF),
              ),
            ),
            const Spacer(),
            const Icon(Icons.calendar_today_outlined, size: 20, color: _gray),
          ],
        ),
      ),
    );
  }
}

/// 성별처럼 두 개 중 하나를 고르는 버튼
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _navy : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? Colors.white : const Color(0xFFA8B0BF),
          ),
        ),
      ),
    );
  }
}

/// 급수 선택 드롭다운
class _ClassDropdown extends StatelessWidget {
  const _ClassDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// 항상 보이는 항목 이름
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFA8B0BF)),
        floatingLabelStyle: const TextStyle(color: _navy),
        filled: true,
        fillColor: Colors.white,
        // 위쪽은 떠오른 라벨이 차지하므로 더 넉넉하게 준다
        contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('선택 안 함')),
        ..._classOptions.entries.map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
