import 'package:flutter/material.dart';

import '../widgets/app_text_field.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _lightNavy = Color(0xFFE9EEF8);
const _red = Color(0xFFD9433C);
const _lightRed = Color(0xFFFCE8E7);
const _bg = Color(0xFFF1F3F8);

/// 스트링 교체 한 건 — 이력과 현재 스트링에 함께 쓴다
class _StringChange {
  const _StringChange({
    required this.name,
    required this.tension,
    required this.date,
  });

  final String name;
  final int tension;
  final DateTime date;
}

/// 그립 교체 한 건 — 그립 교체 입력을 만들면 이름·종류로 구조화한다
class _GripChange {
  const _GripChange({required this.detail, required this.date});

  final String detail;
  final DateTime date;
}

/// 라켓 상세 화면
class RacketDetailScreen extends StatefulWidget {
  const RacketDetailScreen({super.key, required this.name});

  final String name;

  @override
  State<RacketDetailScreen> createState() => _RacketDetailScreenState();
}

class _RacketDetailScreenState extends State<RacketDetailScreen> {
  /// 다음 스트링 교체 알림 날짜 — 임시값. 서버 연동 시 my_racket에서 읽어온다
  DateTime? _stringAlarmDate = DateTime(2026, 8, 21);

  /// 스트링 교체 이력 — 최신순. 첫 항목이 현재 스트링. 서버 연동 시 racket_string_history에서 읽어온다
  final List<_StringChange> _stringHistory = [
    _StringChange(name: 'BG80', tension: 26, date: DateTime(2026, 7, 22)),
    _StringChange(name: 'BG80', tension: 26, date: DateTime(2026, 6, 30)),
    _StringChange(name: 'BG65', tension: 25, date: DateTime(2025, 11, 2)),
  ];

  /// 그립 교체 이력 — 최신순. 첫 항목이 현재 그립. 서버 연동 시 racket_grip_history에서 읽어온다
  final List<_GripChange> _gripHistory = [
    _GripChange(detail: '슈퍼그랩 · 오버그립', date: DateTime(2026, 8, 5)),
    _GripChange(detail: '슈퍼그랩 · 오버그립', date: DateTime(2026, 6, 1)),
  ];

  /// 현재 스트링 = 가장 최근 교체 건. 이력을 모두 지우면 null
  _StringChange? get _currentString =>
      _stringHistory.isEmpty ? null : _stringHistory.first;

  /// 현재 그립 = 가장 최근 교체 건. 이력을 모두 지우면 null
  _GripChange? get _currentGrip =>
      _gripHistory.isEmpty ? null : _gripHistory.first;


  /// 시각을 뗀 오늘 날짜 — 날짜 차이 계산용
  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 알림 날짜까지 남은 일수. 지났으면 음수, 알림이 없으면 null
  int? get _stringDday => _stringAlarmDate?.difference(_today).inDays;

  /// 교체 입력을 받아 현재 스트링과 이력에 반영한다
  Future<void> _addStringChange() async {
    final result = await showModalBottomSheet<_StringChange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _StringChangeSheet(
        initialName: _currentString?.name,
        initialTension: _currentString?.tension,
      ),
    );
    if (result != null) {
      setState(() => _stringHistory.insert(0, result)); // TODO: 서버에 저장
    }
  }

  /// 삭제 확인 다이얼로그 — 삭제를 누르면 true
  Future<bool> _confirmDeleteHistory() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('교체 이력 삭제'),
        content: const Text('이 교체 이력을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: _red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _deleteStringHistory(int index) async {
    if (!await _confirmDeleteHistory()) return;
    setState(() => _stringHistory.removeAt(index)); // TODO: 서버에서 삭제
  }

  Future<void> _deleteGripHistory(int index) async {
    if (!await _confirmDeleteHistory()) return;
    setState(() => _gripHistory.removeAt(index)); // TODO: 서버에서 삭제
  }

  /// 바텀시트로 다음 교체 알림 날짜를 고른다
  Future<void> _editStringAlarm() async {
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AlarmDateSheet(today: _today),
    );
    if (result != null) {
      setState(() => _stringAlarmDate = result); // TODO: 서버에 저장
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final currentString = _currentString;
    final currentGrip = _currentGrip;
    final alarm = _stringAlarmDate;
    final dday = _stringDday;
    return Scaffold(
      appBar: AppBar(
        title: const Text('라켓 상세'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {}, // TODO: 수정 / 방출 메뉴
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 기본 정보
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _lightNavy,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.sports_tennis_outlined,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '요넥스 · 아스트록스',
                                style: TextStyle(fontSize: 13, color: _gray),
                              ),
                            ],
                          ),
                        ),
                        const _Badge(
                          text: '사용 중',
                          color: _navy,
                          bg: _lightNavy,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 스펙 (racket_model)
                    const Row(
                      children: [
                        Expanded(
                          child: _Stat(label: '무게', value: '4U'),
                        ),
                        Expanded(
                          child: _Stat(label: '밸런스', value: '헤드 헤비'),
                        ),
                        Expanded(
                          child: _Stat(label: '플렉스', value: '스티프'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. 사용 내역
              const _Card(
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(label: '구매일', value: '2025.11.02'),
                    ),
                    Expanded(
                      child: _Stat(label: '가격', value: '320,000원'),
                    ),
                    Expanded(
                      child: _Stat(label: '사용', value: '9개월'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 3. 현재 스트링
              const _SectionTitle('스트링'),
              const SizedBox(height: 12),
              _CurrentCard(
                icon: Icons.linear_scale,
                title: currentString == null
                    ? '등록된 스트링 없음'
                    : '${currentString.name} · ${currentString.tension}lbs',
                sub: currentString == null
                    ? '스트링 교체를 눌러 입력하세요'
                    : '마지막 교체 : ${_formatDate(currentString.date)}',
                badge: dday == null
                    ? null
                    : dday >= 0
                        ? 'D-$dday'
                        : 'D+${-dday}',
                badgeColor: dday != null && dday <= 3 ? _red : _navy,
                badgeBg: dday != null && dday <= 3 ? _lightRed : _lightNavy,
                // 다음 교체 알림 날짜 · 변경 버튼
                extra: currentString == null
                    ? null
                    : Row(
                        children: [
                          const Icon(
                            Icons.notifications_none,
                            size: 16,
                            color: _gray,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              alarm == null
                                  ? '다음 교체 알림 없음'
                                  : '다음 교체 ${_formatDate(alarm)}',
                              style: const TextStyle(fontSize: 13, color: _gray),
                            ),
                          ),
                          GestureDetector(
                            onTap: _editStringAlarm,
                            child: Text(
                              alarm == null ? '설정' : '변경',
                              style: const TextStyle(
                                fontSize: 13,
                                color: _navy,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                actionLabel: '스트링 교체',
                onAction: _addStringChange,
              ),
              const SizedBox(height: 12),
              // 스트링 교체 이력 — 최신순
              _HistoryCard(
                count: _stringHistory.length,
                rows: [
                  for (var i = 0; i < _stringHistory.length; i++)
                    _HistoryRow(
                      date: _formatDate(_stringHistory[i].date),
                      detail:
                          '${_stringHistory[i].name} · ${_stringHistory[i].tension}lbs',
                      onDelete: () => _deleteStringHistory(i),
                    ),
                ],
              ),

              const SizedBox(height: 28),

              // 4. 현재 그립
              const _SectionTitle('그립'),
              const SizedBox(height: 12),
              _CurrentCard(
                icon: Icons.gesture,
                title: currentGrip == null ? '등록된 그립 없음' : currentGrip.detail,
                sub: currentGrip == null
                    ? '그립 교체를 눌러 입력하세요'
                    : '마지막 교체 : ${_formatDate(currentGrip.date)}',
                actionLabel: '그립 교체',
                onAction: () {}, // TODO: 그립 교체 입력
              ),
              const SizedBox(height: 12),
              // 그립 교체 이력 — 최신순
              _HistoryCard(
                count: _gripHistory.length,
                rows: [
                  for (var i = 0; i < _gripHistory.length; i++)
                    _HistoryRow(
                      date: _formatDate(_gripHistory[i].date),
                      detail: _gripHistory[i].detail,
                      onDelete: () => _deleteGripHistory(i),
                    ),
                ],
              ),

              const SizedBox(height: 28),

              // 5. 메모
              const _SectionTitle('메모'),
              const SizedBox(height: 12),
              const _Card(
                child: Text(
                  '스매시용. 26lbs 넘기면 팔꿈치 아픔.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 흰 배경 둥근 카드
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

/// 섹션 제목
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
    );
  }
}

/// 상태 배지
class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color, required this.bg});

  final String text;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 라벨(회색) 위, 값(굵게) 아래
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _gray)),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// 현재 스트링 / 그립 카드 — 정보 + 교체 버튼
class _CurrentCard extends StatelessWidget {
  const _CurrentCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.actionLabel,
    required this.onAction,
    this.badge,
    this.badgeColor,
    this.badgeBg,
    this.extra,
  });

  final IconData icon;
  final String title;
  final String sub;

  /// 상태 배지 — 없으면 표시 안 함
  final String? badge;
  final Color? badgeColor;
  final Color? badgeBg;
  final String actionLabel;
  final VoidCallback onAction;

  /// 정보 줄과 버튼 사이에 끼울 추가 줄 (예: 교체 주기)
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _lightNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _navy, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: const TextStyle(fontSize: 13, color: _gray),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                _Badge(text: badge!, color: badgeColor!, bg: badgeBg!),
            ],
          ),
          if (extra != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            extra!,
          ],
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              foregroundColor: _navy,
              side: const BorderSide(color: _lightNavy, width: 1.5),
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// 교체 이력 카드 — "교체 이력 N회" 제목 + 줄 목록 (줄 사이 구분선)
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.count, required this.rows});

  final int count;
  final List<_HistoryRow> rows;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '교체 이력 $count회',
            style: const TextStyle(
              fontSize: 13,
              color: _gray,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 24), // 첫 줄 앞엔 선 없음
            rows[i],
          ],
        ],
      ),
    );
  }
}

/// 스트링 교체 입력 바텀시트 — 저장하면 _StringChange를 돌려준다
class _StringChangeSheet extends StatefulWidget {
  const _StringChangeSheet({
    required this.initialName,
    required this.initialTension,
  });

  /// 현재 스트링 이름 — 같은 스트링으로 교체하는 경우가 많아 미리 채워둔다. 없으면 빈칸
  final String? initialName;
  final int? initialTension;

  @override
  State<_StringChangeSheet> createState() => _StringChangeSheetState();
}

class _StringChangeSheetState extends State<_StringChangeSheet> {
  late final _nameController =
      TextEditingController(text: widget.initialName ?? '');
  late final _tensionController = TextEditingController(
    text: widget.initialTension == null ? '' : '${widget.initialTension}',
  );

  /// 교체일 — 기본은 오늘
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _tensionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  void _save() {
    final name = _nameController.text.trim();
    final tension = int.tryParse(_tensionController.text);
    if (name.isEmpty || tension == null || tension <= 0) return;
    Navigator.pop(
      context,
      _StringChange(name: name, tension: tension, date: _date),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 키보드가 올라오면 그만큼 시트를 밀어올린다
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '스트링 교체',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          _SheetLabel('스트링명'),
          AppTextField(hint: '입력', controller: _nameController),
          const SizedBox(height: 16),
          _SheetLabel('텐션'),
          AppTextField(
            hint: 'lbs',
            controller: _tensionController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _SheetLabel('교체일'),
          InkWell(
            onTap: _pickDate,
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
                    _formatDate(_date),
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: _gray,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: _navy,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '저장',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// 다음 교체 알림 날짜 선택 바텀시트 — 고르면 날짜를 돌려준다
class _AlarmDateSheet extends StatelessWidget {
  const _AlarmDateSheet({required this.today});

  final DateTime today;

  /// 달력에서 직접 고른다
  Future<void> _pickCustom(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
    );
    if (picked != null && context.mounted) Navigator.pop(context, picked);
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final options = [
      (label: '2주 후', date: today.add(const Duration(days: 14))),
      (label: '30일 후', date: today.add(const Duration(days: 30))),
      (label: '60일 후', date: today.add(const Duration(days: 60))),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '다음 교체 알림',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            for (final option in options)
              _AlarmOption(
                label: option.label,
                sub: _formatDate(option.date),
                onTap: () => Navigator.pop(context, option.date),
              ),
            _AlarmOption(
              label: '직접 선택',
              sub: '달력에서 고르기',
              onTap: () => _pickCustom(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// 알림 날짜 선택지 한 줄
class _AlarmOption extends StatelessWidget {
  const _AlarmOption({
    required this.label,
    required this.sub,
    required this.onTap,
  });

  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(sub, style: const TextStyle(fontSize: 13, color: _gray)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 바텀시트 입력칸 위의 작은 라벨
class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: _gray,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 교체 이력 한 줄 — 날짜 · 내용 · 삭제 버튼
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.date,
    required this.detail,
    required this.onDelete,
  });

  final String date;
  final String detail;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(date, style: const TextStyle(fontSize: 13, color: _gray)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            detail,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.close, size: 18, color: _gray),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
