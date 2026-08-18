import 'package:flutter/material.dart';

import '../widgets/app_text_field.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _hint = Color(0xFFA8B0BF);

/// 브랜드별 라켓 모델 — 임시 데이터 (서버 RacketModel 연동 전)
const _racketModels = {
  '요넥스': ['아스트록스 99', '아스트록스 88D', '나노플레어 800'],
  '빅터': ['썬더 TK-F', '오라 스피드 100X'],
  '리닝': ['에어로너트 9000', '액스포스 80'],
};

/// 브랜드별 신발 모델 — 임시 데이터 (서버 ShoeModel 연동 전)
const _shoeModels = {
  '요넥스': ['파워쿠션 65Z', '에어러스 Z'],
  '빅터': ['A970', 'P9200'],
  '리닝': ['레인저 TD', '사가 라이트'],
};

/// 그립 종류 — 서버 GripType과 같은 값
const _gripTypes = {'OVER': '오버그립', 'TOWEL': '타월그립', 'CUSHION': '쿠션그립'};

/// 장비 등록 화면
class EquipmentRegisterScreen extends StatefulWidget {
  const EquipmentRegisterScreen({super.key});

  @override
  State<EquipmentRegisterScreen> createState() =>
      _EquipmentRegisterScreenState();
}

class _EquipmentRegisterScreenState extends State<EquipmentRegisterScreen> {
  /// 'RACKET' 또는 'SHOE'
  String _type = 'RACKET';

  // 공통
  String? _brand;
  String? _model;
  DateTime? _purchaseDate;
  final _priceController = TextEditingController();

  // 라켓 전용
  final _stringController = TextEditingController();
  final _tensionController = TextEditingController();
  DateTime? _stringDate; // 직접 안 고르면 구매일을 쓴다
  final _gripController = TextEditingController();
  String? _gripType;
  DateTime? _gripDate; // 직접 안 고르면 구매일을 쓴다

  bool get _isRacket => _type == 'RACKET';

  /// 종류에 따라 보여줄 브랜드→모델 목록
  Map<String, List<String>> get _models =>
      _isRacket ? _racketModels : _shoeModels;

  @override
  void dispose() {
    _priceController.dispose();
    _stringController.dispose();
    _tensionController.dispose();
    _gripController.dispose();
    super.dispose();
  }

  /// 종류를 바꾸면 브랜드·모델은 초기화 (목록이 달라지므로)
  void _changeType(String type) {
    setState(() {
      _type = type;
      _brand = null;
      _model = null;
    });
  }

  /// 달력을 띄워 날짜를 고른다. 취소하면 null
  Future<DateTime?> _pickDate(DateTime? current) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await _pickDate(_purchaseDate);
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _pickStringDate() async {
    final picked = await _pickDate(_stringDate ?? _purchaseDate);
    if (picked != null) setState(() => _stringDate = picked);
  }

  Future<void> _pickGripDate() async {
    final picked = await _pickDate(_gripDate ?? _purchaseDate);
    if (picked != null) setState(() => _gripDate = picked);
  }

  /// 날짜 칸에 보여줄 글자 — 없으면 '선택'
  String _dateLabel(DateTime? date) => date == null ? '선택' : _formatDate(date);

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  void _submit() {
    // TODO: 서버 등록 API 연결
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('장비 등록'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 종류 선택
              const _SectionLabel('종류'),
              Row(
                children: [
                  Expanded(
                    child: _ChoiceButton(
                      label: '라켓',
                      selected: _isRacket,
                      onTap: () => _changeType('RACKET'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ChoiceButton(
                      label: '신발',
                      selected: !_isRacket,
                      onTap: () => _changeType('SHOE'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const _SectionLabel('기본 정보'),

              // 브랜드 → 모델 순서로 고른다
              _Labeled(
                label: '브랜드',
                child: _Dropdown(
                  value: _brand,
                  items: _models.keys.toList(),
                  onChanged: (value) => setState(() {
                    _brand = value;
                    _model = null; // 브랜드 바뀌면 모델 다시 선택
                  }),
                ),
              ),
              const SizedBox(height: 16),
              _Labeled(
                label: _isRacket ? '라켓명' : '신발명',
                child: _Dropdown(
                  value: _model,
                  items: _brand == null ? const [] : _models[_brand]!,
                  onChanged: (value) => setState(() => _model = value),
                ),
              ),
              const SizedBox(height: 16),
              _Labeled(
                label: '구매일',
                child: _PickerBox(
                  label: _dateLabel(_purchaseDate),
                  selected: _purchaseDate != null,
                  onTap: _pickPurchaseDate,
                ),
              ),
              const SizedBox(height: 16),
              _Labeled(
                label: '가격',
                child: AppTextField(
                  hint: '원',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                ),
              ),

              // 라켓일 때만 스트링·그립 정보
              if (_isRacket) ...[
                const SizedBox(height: 32),
                const _SectionLabel('스트링'),
                _Labeled(
                  label: '스트링명',
                  child: AppTextField(
                    hint: '입력',
                    controller: _stringController,
                  ),
                ),
                const SizedBox(height: 16),
                _Labeled(
                  label: '텐션',
                  child: AppTextField(
                    hint: 'lbs',
                    controller: _tensionController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 16),
                // 직접 안 고르면 구매일이 그대로 들어간다
                _Labeled(
                  label: '교체일',
                  child: _PickerBox(
                    label: _dateLabel(_stringDate ?? _purchaseDate),
                    selected: (_stringDate ?? _purchaseDate) != null,
                    onTap: _pickStringDate,
                  ),
                ),

                const SizedBox(height: 32),
                const _SectionLabel('그립'),
                _Labeled(
                  label: '그립명',
                  child: AppTextField(hint: '입력', controller: _gripController),
                ),
                const SizedBox(height: 16),
                _Labeled(
                  label: '그립 종류',
                  child: _Dropdown(
                    value: _gripType,
                    items: _gripTypes.keys.toList(),
                    itemLabel: (key) => _gripTypes[key]!,
                    onChanged: (value) => setState(() => _gripType = value),
                  ),
                ),
                const SizedBox(height: 16),
                _Labeled(
                  label: '교체일',
                  child: _PickerBox(
                    label: _dateLabel(_gripDate ?? _purchaseDate),
                    selected: (_gripDate ?? _purchaseDate) != null,
                    onTap: _pickGripDate,
                  ),
                ),
              ],

              const SizedBox(height: 32),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '등록하기',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
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

/// 입력칸 왼쪽 위에 작은 라벨을 붙인다
class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: _gray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// 라켓/신발처럼 둘 중 하나를 고르는 버튼
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
            color: selected ? Colors.white : _hint,
          ),
        ),
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
                color: selected ? Colors.black87 : _hint,
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

/// 목록에서 하나 고르는 드롭다운
class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  /// 화면에 보여줄 이름이 값과 다를 때 (예: 'OVER' → '오버그립')
  final String Function(String)? itemLabel;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // key를 value로 두면 값이 바뀔 때 위젯을 새로 만들어 초기값이 반영된다
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      // 값이 없을 때 안쪽에 보이는 안내 문구
      hint: const Text('선택', style: TextStyle(color: _hint)),
      decoration: InputDecoration(
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
      items: [
        for (final item in items)
          DropdownMenuItem(
            value: item,
            child: Text(itemLabel == null ? item : itemLabel!(item)),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
