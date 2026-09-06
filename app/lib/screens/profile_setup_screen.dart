import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../data/app_repositories.dart';
import '../data/repositories.dart';
import '../services/session.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, this.initialProfile});

  final LocalProfile? initialProfile;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nickname = TextEditingController();
  final _email = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _localClass;
  String? _nationalClass;
  bool _saving = false;

  static const _classes = ['S', 'A', 'B', 'C', 'D', 'E', 'F'];

  bool get _isEditing => widget.initialProfile != null;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    if (profile == null) return;
    _nickname.text = profile.nickname;
    _email.text = profile.email ?? '';
    _birthDate = profile.birthDate;
    _gender = profile.gender;
    _localClass = profile.localClass;
    _nationalClass = profile.nationalClass;
  }

  @override
  void dispose() {
    _nickname.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final nickname = _nickname.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임을 입력해 주세요.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await AppRepositories.profile.save(
        LocalProfile(
          nickname: nickname,
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          birthDate: _birthDate,
          gender: _gender,
          localClass: _localClass,
          nationalClass: _nationalClass,
        ),
      );
      Session.nickname = nickname;
      if (!mounted) return;
      if (_isEditing) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정보를 저장하지 못했어요. 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '내 정보 수정' : '내 정보 설정'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing
                    ? '내 정보를 확인하고\n필요한 내용을 수정해 주세요.'
                    : '민터너리를 시작하기 전에\n간단한 정보를 알려주세요.',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              const Text('정보는 이 기기에만 저장됩니다.', style: TextStyle(color: _gray)),
              const SizedBox(height: 32),
              const _Label('닉네임 *'),
              AppTextField(hint: '닉네임', controller: _nickname, maxLength: 20),
              const SizedBox(height: 16),
              const _Label('이메일'),
              AppTextField(
                hint: '선택 입력',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const _Label('생년월일'),
              _Picker(
                label: _birthDate == null
                    ? '선택'
                    : '${_birthDate!.year}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.day.toString().padLeft(2, '0')}',
                onTap: _pickBirthDate,
              ),
              const SizedBox(height: 16),
              const _Label('성별'),
              _Dropdown(
                value: _gender,
                items: const {'MALE': '남성', 'FEMALE': '여성'},
                onChanged: (value) => setState(() => _gender = value),
              ),
              const SizedBox(height: 16),
              const _Label('구 대회 급수'),
              _ClassDropdown(
                value: _localClass,
                items: _classes,
                onChanged: (value) => setState(() => _localClass = value),
              ),
              const SizedBox(height: 16),
              const _Label('전국 대회 급수'),
              _ClassDropdown(
                value: _nationalClass,
                items: _classes,
                onChanged: (value) => setState(() => _nationalClass = value),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? '저장하기' : '시작하기',
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

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 7),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

class _Picker extends StatelessWidget {
  const _Picker({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
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
          Text(label),
          const Spacer(),
          const Icon(Icons.calendar_today_outlined, color: _gray),
        ],
      ),
    ),
  );
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField2<String>(
    key: ValueKey(value),
    valueListenable: ValueNotifier(value),
    isExpanded: true,
    hint: const Text('선택', style: TextStyle(color: _gray)),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    buttonStyleData: const FormFieldButtonStyleData(padding: EdgeInsets.zero),
    menuItemStyleData: const MenuItemStyleData(
      useDecorationHorizontalPadding: true,
    ),
    items: items.entries
        .map((e) => DropdownItem(value: e.key, child: Text(e.value)))
        .toList(),
    dropdownStyleData: DropdownStyleData(
      maxHeight: 360,
      anchoredMinHeight: 240,
      offset: Offset.zero,
      isOverButton: false,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
    ),
    onChanged: onChanged,
  );
}

class _ClassDropdown extends StatelessWidget {
  const _ClassDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) => _Dropdown(
    value: value,
    items: {for (final item in items) item: item},
    onChanged: onChanged,
  );
}
