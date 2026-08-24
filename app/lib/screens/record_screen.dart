import 'package:flutter/material.dart';

import '../models/workout_record.dart';
import '../services/record_api.dart';
import '../widgets/app_text_field.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _blue = Color(0xFF4E7DE0); // 일반 운동 — 선택 원(네이비)과 구분되는 밝은 파랑
const _lightBlue = Color(0xFFE8EEFB);
const _green = Color(0xFF3BA776); // 레슨
const _lightGreen = Color(0xFFE3F3EC);
const _orange = Color(0xFFE8A23D); // 대회
const _lightOrange = Color(0xFFFBF1DA);

/// 기록 종류 — 일반 운동 / 레슨 / 대회
enum _RecordType {
  general('GENERAL'),
  lesson('LESSON'),
  tournament('TOURNAMENT');

  const _RecordType(this.serverValue);

  /// 서버 WorkoutType과 같은 값
  final String serverValue;

  static _RecordType from(String serverValue) => values.firstWhere(
    (type) => type.serverValue == serverValue,
    orElse: () => general,
  );
}

extension on _RecordType {
  String get label => switch (this) {
    _RecordType.general => '일반 운동',
    _RecordType.lesson => '레슨',
    _RecordType.tournament => '대회',
  };

  Color get color => switch (this) {
    _RecordType.general => _blue,
    _RecordType.lesson => _green,
    _RecordType.tournament => _orange,
  };

  Color get bg => switch (this) {
    _RecordType.general => _lightBlue,
    _RecordType.lesson => _lightGreen,
    _RecordType.tournament => _lightOrange,
  };
}

/// 기록 탭 — 월 캘린더 + 선택한 날짜의 기록
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  /// 보고 있는 달의 기록. 아직 못 불러왔으면 null
  List<WorkoutRecord>? _records;
  String? _error;

  /// 보고 있는 달 (1일로 고정)
  late DateTime _month;

  /// 선택한 날짜
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() {
      _records = null;
      _error = null;
    });
    try {
      final records = await RecordApi.fetchMonth(_month.year, _month.month);
      if (!mounted) return;
      setState(() => _records = records);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _moveMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selected = DateTime(_month.year, _month.month, 1);
    });
    _loadMonth();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// 해당 날짜의 기록들
  List<WorkoutRecord> _recordsOn(DateTime date) =>
      (_records ?? const []).where((r) => _sameDay(r.date, date)).toList();

  /// 기록 남기기 화면을 연다. 저장에 성공하면 저장한 날짜가 돌아온다
  Future<void> _openForm() async {
    final savedDate = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(
        builder: (_) => _RecordFormScreen(initialDate: _selected),
      ),
    );
    if (savedDate == null) return;
    // 저장한 날짜가 보이도록 이동 후 다시 불러온다
    setState(() {
      _month = DateTime(savedDate.year, savedDate.month);
      _selected = DateTime(savedDate.year, savedDate.month, savedDate.day);
    });
    await _loadMonth();
  }

  /// 확인 후 기록을 삭제한다
  Future<void> _deleteRecord(WorkoutRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 기록을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD9433C),
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await RecordApi.delete(record.id);
      await _loadMonth();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 월 이동
          Row(
            children: [
              const Expanded(
                child: Text(
                  '운동 기록',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ),
              _MonthNav(
                label: '${_month.year}년 ${_month.month}월',
                onPrev: () => _moveMonth(-1),
                onNext: () => _moveMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            children: [
              Text(_error!, style: const TextStyle(color: _gray)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadMonth,
                child: const Text(
                  '다시 시도',
                  style: TextStyle(color: _navy, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_records == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator(color: _navy)),
      );
    }

    final selectedRecords = _recordsOn(_selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 캘린더 카드
        _Card(
          child: Column(
            children: [
              _Calendar(
                month: _month,
                selected: _selected,
                recordsOf: _recordsOn,
                onSelect: (date) => setState(() => _selected = date),
              ),
              const SizedBox(height: 16),
              // 범례
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final type in _RecordType.values) ...[
                    if (type != _RecordType.values.first)
                      const SizedBox(width: 16),
                    Container(
                      width: 12,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: type.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      type.label,
                      style: const TextStyle(fontSize: 12, color: _gray),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // 선택한 날짜의 기록
        Text(
          '${_selected.month}월 ${_selected.day}일의 기록',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (final record in selectedRecords) ...[
          _RecordCard(record: record, onDelete: () => _deleteRecord(record)),
          const SizedBox(height: 12),
        ],
        if (selectedRecords.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '이 날의 기록이 없어요',
              style: TextStyle(fontSize: 14, color: _gray),
            ),
          ),
        const SizedBox(height: 4),
        _AddRecordButton(onTap: _openForm),
      ],
    );
  }
}

/// ‹ 2026년 7월 › 모양의 월 이동 컨트롤
class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onPrev,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.chevron_left, size: 20, color: _gray),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        InkWell(
          onTap: onNext,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.chevron_right, size: 20, color: _gray),
          ),
        ),
      ],
    );
  }
}

/// 월 캘린더 — 일요일 시작, 날짜 아래 기록 종류별 점
class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.month,
    required this.selected,
    required this.recordsOf,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final List<WorkoutRecord> Function(DateTime) recordsOf;
  final ValueChanged<DateTime> onSelect;

  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // 1일이 일요일이면 0 (weekday: 월1 ~ 일7)
    final firstOffset = DateTime(month.year, month.month, 1).weekday % 7;
    final weeks = ((firstOffset + daysInMonth) / 7).ceil();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: [
        // 요일 헤더
        Row(
          children: [
            for (final name in _weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        for (var w = 0; w < weeks; w++)
          Row(
            children: List.generate(7, (c) {
              final day = w * 7 + c - firstOffset + 1;
              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox(height: 54));
              }
              final date = DateTime(month.year, month.month, day);
              return Expanded(
                child: _DayCell(
                  date: date,
                  isSelected:
                      selected.year == date.year &&
                      selected.month == date.month &&
                      selected.day == date.day,
                  isToday: date == today,
                  isFuture: date.isAfter(today),
                  types: [
                    // 같은 종류가 여러 건이어도 점은 하나만
                    for (final type in _RecordType.values)
                      if (recordsOf(
                        date,
                      ).any((r) => _RecordType.from(r.type) == type))
                        type,
                  ],
                  onTap: () => onSelect(date),
                ),
              );
            }),
          ),
      ],
    );
  }
}

/// 캘린더 하루 칸 — 날짜 숫자 + 기록 점
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isFuture,
    required this.types,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isFuture;
  final List<_RecordType> types;
  final VoidCallback onTap;

  /// 선택: 진한 사각 / 기록 있는 날: 첫 종류의 연한 색 채움 / 오늘: 테두리 링
  BoxDecoration? get _numberDecoration {
    if (isSelected) {
      return BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(10),
      );
    }
    if (types.isEmpty && !isToday) return null;
    return BoxDecoration(
      color: types.isEmpty ? null : types.first.bg,
      borderRadius: BorderRadius.circular(10),
      border: isToday ? Border.all(color: _navy, width: 1.5) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: _numberDecoration,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : types.isNotEmpty
                      ? types.first.color
                      : isToday
                      ? _navy
                      : isFuture
                      ? const Color(0xFFC3C9D4)
                      : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 3), // 날짜 원과 막대 사이 간격
            // 기록 막대 — 세로로 쌓는다. types가 일반 운동→레슨→대회 순서라 순서가 보장된다
            SizedBox(
              height: 15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final type in types) ...[
                    if (type != types.first) const SizedBox(height: 1.5),
                    Container(
                      width: 16,
                      height: 3,
                      decoration: BoxDecoration(
                        color: type.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 기록 카드 — 종류 태그 + 제목 + 설명 + 메모 + 삭제 버튼
class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onDelete});

  final WorkoutRecord record;
  final VoidCallback onDelete;

  /// "김코치 · 관악체육관", "구민체육센터 · 준우승" 형식의 설명 줄
  String get _sub => [
    if (record.coach?.isNotEmpty == true) record.coach!,
    if (record.place?.isNotEmpty == true) record.place!,
    if (record.result?.isNotEmpty == true) record.result!,
  ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final type = _RecordType.from(record.type);
    final memo = record.memo ?? '';
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: type.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: type.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  record.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
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
          ),
          if (_sub.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(_sub, style: const TextStyle(fontSize: 13, color: _gray)),
          ],
          if (memo.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(memo, style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ],
      ),
    );
  }
}

/// 기록 남기기 화면 — 저장하면 입력값(_RecordDraft)을 돌려준다
class _RecordFormScreen extends StatefulWidget {
  const _RecordFormScreen({required this.initialDate});

  /// 캘린더에서 선택돼 있던 날짜로 시작한다
  final DateTime initialDate;

  @override
  State<_RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<_RecordFormScreen> {
  _RecordType _type = _RecordType.general;
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _coachController = TextEditingController();
  final _resultController = TextEditingController();
  final _memoController = TextEditingController();

  /// 캘린더에서 미래 날짜를 선택한 채 들어와도 오늘을 넘지 않게 잘라낸다
  late DateTime _date = _clampToToday(widget.initialDate);

  /// 저장 요청 중이면 true — 버튼을 잠가 중복 요청을 막는다
  bool _saving = false;

  bool get _isTournament => _type == _RecordType.tournament;

  static DateTime _clampToToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isAfter(today) ? today : date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _coachController.dispose();
    _resultController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 10);
    // 초기값이 피커 범위를 벗어나면 크래시가 나므로 범위 안으로 잘라낸다
    var initial = _date.isAfter(now) ? now : _date;
    if (initial.isBefore(first)) initial = first;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 서버에 저장하고, 성공하면 저장한 날짜를 들고 닫는다.
  /// 실패하면 폼을 유지해 입력 내용이 사라지지 않게 한다
  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage(_isTournament ? '대회명을 입력해 주세요.' : '한 줄 기록을 입력해 주세요.');
      return;
    }
    setState(() => _saving = true);
    try {
      await RecordApi.create(
        date: _date,
        type: _type.serverValue,
        title: title,
        place: _placeController.text.trim(),
        // 코치는 레슨, 결과는 대회일 때만 의미가 있다
        coach: _type == _RecordType.lesson ? _coachController.text.trim() : '',
        result: _isTournament ? _resultController.text.trim() : '',
        memo: _memoController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, _date);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기록 남기기'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FormLabel('종류'),
              Row(
                children: [
                  for (final type in _RecordType.values) ...[
                    if (type != _RecordType.values.first)
                      const SizedBox(width: 10),
                    Expanded(
                      child: _TypeButton(
                        type: type,
                        selected: _type == type,
                        onTap: () => setState(() => _type = type),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),
              // 대회는 대회명을, 나머지는 한 줄 기록을 받는다
              _FormLabel(_isTournament ? '대회명' : '한 줄 기록'),
              AppTextField(
                hint: _isTournament ? '예: 구민 배드민턴 대회' : '예: 클럽 정기 운동',
                controller: _titleController,
                maxLength: 100,
              ),

              const SizedBox(height: 16),
              const _FormLabel('날짜'),
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
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
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

              const SizedBox(height: 16),
              const _FormLabel('장소'),
              AppTextField(
                hint: '예: 관악체육관',
                controller: _placeController,
                maxLength: 100,
              ),

              // 레슨일 때만 코치명
              if (_type == _RecordType.lesson) ...[
                const SizedBox(height: 16),
                const _FormLabel('코치'),
                AppTextField(
                  hint: '예: 김코치',
                  controller: _coachController,
                  maxLength: 50,
                ),
              ],

              // 대회일 때만 결과
              if (_isTournament) ...[
                const SizedBox(height: 16),
                const _FormLabel('결과'),
                AppTextField(
                  hint: '예: 준우승, 조별 예선 탈락',
                  controller: _resultController,
                  maxLength: 100,
                ),
              ],

              const SizedBox(height: 16),
              const _FormLabel('메모'),
              // 여러 줄 입력 — AppTextField는 한 줄이라 직접 만든다
              TextField(
                controller: _memoController,
                maxLines: 4,
                maxLength: 500, // 서버 컬럼 제한과 동일. 카운터는 그대로 보여준다
                decoration: InputDecoration(
                  hintText: '오늘 운동에서 기억할 것을 남겨보세요',
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
                    : const Text(
                        '저장',
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

/// 입력칸 왼쪽 위의 작은 라벨
class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);

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

/// 기록 종류 선택 버튼 — 선택하면 종류 색으로 칠해진다
class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final _RecordType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? type.color : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          type.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? Colors.white : const Color(0xFFA8B0BF),
          ),
        ),
      ),
    );
  }
}

/// 점선 테두리의 "+ 기록 남기기" 버튼
class _AddRecordButton extends StatelessWidget {
  const _AddRecordButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: const SizedBox(
          width: double.infinity,
          height: 54,
          child: Center(
            child: Text(
              '+ 기록 남기기',
              style: TextStyle(
                fontSize: 15,
                color: _navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 둥근 사각형 점선 테두리
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB9C2D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(16),
        ),
      );

    // 경로를 따라가며 일정 간격으로 짧은 선을 그린다
    const dash = 6.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
