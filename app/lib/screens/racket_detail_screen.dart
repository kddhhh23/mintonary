import 'package:flutter/material.dart';

import '../data/app_repositories.dart';
import '../models/equipment.dart';
import '../widgets/app_text_field.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _lightNavy = Color(0xFFE9EEF8);
const _red = Color(0xFFD9433C);
const _lightRed = Color(0xFFFCE8E7);
const _bg = Color(0xFFF1F3F8);

/// 그립 종류 — 서버 GripType과 같은 값
const _gripTypes = {'OVER': '오버그립', 'TOWEL': '타월그립', 'CUSHION': '쿠션그립'};

/// 스트링 교체 입력 결과
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

/// 그립 교체 입력 결과
class _GripChange {
  const _GripChange({
    required this.name,
    required this.type,
    required this.date,
  });

  final String name;

  /// OVER, TOWEL, CUSHION
  final String type;
  final DateTime date;
}

/// 라켓 상세 화면
class RacketDetailScreen extends StatefulWidget {
  const RacketDetailScreen({super.key, required this.equipmentId});

  final int equipmentId;

  @override
  State<RacketDetailScreen> createState() => _RacketDetailScreenState();
}

class _RacketDetailScreenState extends State<RacketDetailScreen> {
  EquipmentDetail? _detail;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await AppRepositories.equipment.fetchDetail(
        widget.equipmentId,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// API 호출 실패 메시지를 스낵바로 보여준다
  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
    );
  }

  /// 시각을 뗀 오늘 날짜 — 날짜 차이 계산용
  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 바텀시트로 사용 상태를 고른다
  Future<void> _editStatus() async {
    final detail = _detail;
    if (detail == null) return;
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _StatusSheet(inUse: detail.inUse),
    );
    if (result == null || result == detail.inUse) return;
    try {
      await AppRepositories.equipment.setStatus(widget.equipmentId, result);
      await _load();
    } catch (e) {
      if (mounted) _showError(e);
    }
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
    if (result == null) return;
    try {
      await AppRepositories.equipment.setStringAlarm(
        widget.equipmentId,
        result,
      );
      await _load();
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  /// 교체 입력을 받아 서버에 기록한다
  Future<void> _addStringChange() async {
    final current = _detail?.racket?.stringHistories.firstOrNull;
    final result = await showModalBottomSheet<_StringChange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _StringChangeSheet(
        initialName: current?.name,
        initialTension: current?.tension,
      ),
    );
    if (result == null) return;
    try {
      await AppRepositories.equipment.addStringChange(
        widget.equipmentId,
        name: result.name,
        tension: result.tension,
        strungAt: result.date,
      );
      await _load();
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  /// 그립 교체 입력을 받아 서버에 기록한다
  Future<void> _addGripChange() async {
    final current = _detail?.racket?.gripHistories.firstOrNull;
    final result = await showModalBottomSheet<_GripChange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _GripChangeSheet(
        initialName: current?.name,
        initialType: current?.type,
      ),
    );
    if (result == null) return;
    try {
      await AppRepositories.equipment.addGripChange(
        widget.equipmentId,
        name: result.name,
        type: result.type,
        wrappedAt: result.date,
      );
      await _load();
    } catch (e) {
      if (mounted) _showError(e);
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

  Future<void> _deleteStringHistory(int historyId) async {
    if (!await _confirmDeleteHistory()) return;
    try {
      await AppRepositories.equipment.deleteStringChange(
        widget.equipmentId,
        historyId,
      );
      await _load();
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  Future<void> _deleteGripHistory(int historyId) async {
    if (!await _confirmDeleteHistory()) return;
    try {
      await AppRepositories.equipment.deleteGripChange(
        widget.equipmentId,
        historyId,
      );
      await _load();
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  /// 1234567 → 1,234,567
  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  /// 구매일부터 지금까지 몇 개월 썼는지
  String _usageLabel(DateTime? purchaseDate) {
    if (purchaseDate == null) return '-';
    final now = DateTime.now();
    var months =
        (now.year - purchaseDate.year) * 12 + now.month - purchaseDate.month;
    if (now.day < purchaseDate.day) months--;
    return months < 1 ? '1개월 미만' : '$months개월';
  }

  /// 서버 표기(U4)를 화면 표기(4U)로
  String _weightLabel(String? weight) =>
      weight == null ? '-' : '${weight.substring(1)}U';

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: _gray)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _load,
              child: const Text(
                '다시 시도',
                style: TextStyle(color: _navy, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    final detail = _detail;
    final racket = detail?.racket;
    if (detail == null || racket == null) {
      return const Center(child: CircularProgressIndicator(color: _navy));
    }

    final currentString = racket.stringHistories.firstOrNull;
    final currentGrip = racket.gripHistories.firstOrNull;
    final alarm = racket.stringAlarmDate;
    final dday = alarm?.difference(_today).inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 기본 정보 + 스펙
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // 태그가 이름 줄 상단에 붙도록 위 정렬
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${racket.brand} ${racket.name}',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            racket.series == null
                                ? racket.brand
                                : '${racket.brand} · ${racket.series}',
                            style: const TextStyle(fontSize: 13, color: _gray),
                          ),
                        ],
                      ),
                    ),
                    // 사용 상태 태그 — 누르면 변경
                    const SizedBox(width: 10),
                    _StatusTag(inUse: detail.inUse, onTap: _editStatus),
                  ],
                ),
                const SizedBox(height: 20),
                // 스펙 (racket_model)
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: '무게',
                        value: _weightLabel(racket.weight),
                      ),
                    ),
                    Expanded(
                      child: _Stat(label: '밸런스', value: racket.balance ?? '-'),
                    ),
                    Expanded(
                      child: _Stat(label: '플렉스', value: racket.flex ?? '-'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. 사용 내역
          _Card(
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: '구매일',
                    value: detail.purchaseDate == null
                        ? '-'
                        : _formatDate(detail.purchaseDate!),
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: '가격',
                    value: detail.price == null
                        ? '-'
                        : '${_formatPrice(detail.price!)}원',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: '사용',
                    value: _usageLabel(detail.purchaseDate),
                  ),
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
                : '${currentString.name}${currentString.tension == null ? '' : ' · ${currentString.tension}lbs'}',
            sub: currentString == null
                ? '스트링 교체를 눌러 입력하세요'
                : '마지막 교체 : ${_formatDate(currentString.strungAt)}',
            badge: dday == null
                ? null
                : dday >= 0
                ? 'D-$dday'
                : 'D+${-dday}',
            badgeColor: dday != null && dday <= 3 ? _red : _navy,
            badgeBg: dday != null && dday <= 3 ? _lightRed : _lightNavy,
            // 다음 교체 알림 날짜 · 변경 버튼
            extra: Row(
              children: [
                const Icon(Icons.notifications_none, size: 16, color: _gray),
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
            count: racket.stringHistories.length,
            rows: [
              for (final history in racket.stringHistories)
                _HistoryRow(
                  date: _formatDate(history.strungAt),
                  detail:
                      '${history.name}${history.tension == null ? '' : ' · ${history.tension}lbs'}',
                  onDelete: () => _deleteStringHistory(history.id),
                ),
            ],
          ),

          const SizedBox(height: 28),

          // 4. 현재 그립
          const _SectionTitle('그립'),
          const SizedBox(height: 12),
          _CurrentCard(
            icon: Icons.gesture,
            title: currentGrip == null
                ? '등록된 그립 없음'
                : '${currentGrip.name}${_gripTypes[currentGrip.type] == null ? '' : ' · ${_gripTypes[currentGrip.type]}'}',
            sub: currentGrip == null
                ? '그립 교체를 눌러 입력하세요'
                : '마지막 교체 : ${_formatDate(currentGrip.wrappedAt)}',
            actionLabel: '그립 교체',
            onAction: _addGripChange,
          ),
          const SizedBox(height: 12),
          // 그립 교체 이력 — 최신순
          _HistoryCard(
            count: racket.gripHistories.length,
            rows: [
              for (final history in racket.gripHistories)
                _HistoryRow(
                  date: _formatDate(history.wrappedAt),
                  detail:
                      '${history.name}${_gripTypes[history.type] == null ? '' : ' · ${_gripTypes[history.type]}'}',
                  onDelete: () => _deleteGripHistory(history.id),
                ),
            ],
          ),

          const SizedBox(height: 28),

          // 5. 메모
          const _SectionTitle('메모'),
          const SizedBox(height: 12),
          _Card(
            child: Text(
              detail.memo?.isNotEmpty == true ? detail.memo! : '메모 없음',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: detail.memo?.isNotEmpty == true ? null : _gray,
              ),
            ),
          ),
        ],
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

/// 사용 상태 태그 — 아래 화살표로 눌러서 바꿀 수 있음을 보여준다
class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.inUse, required this.onTap});

  final bool inUse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = inUse ? _navy : _gray;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: inUse ? _lightNavy : _bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              inUse ? '사용 중' : '미사용',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

/// 사용 상태 선택 바텀시트 — 고르면 사용 중 여부(bool)를 돌려준다
class _StatusSheet extends StatelessWidget {
  const _StatusSheet({required this.inUse});

  final bool inUse;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '사용 상태',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _StatusOption(
              label: '사용 중',
              selected: inUse,
              onTap: () => Navigator.pop(context, true),
            ),
            _StatusOption(
              label: '미사용',
              selected: !inUse,
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }
}

/// 사용 상태 선택지 한 줄 — 현재 상태에 체크 표시
class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
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
              if (selected) const Icon(Icons.check, size: 20, color: _navy),
            ],
          ),
        ),
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

  /// 정보 줄과 버튼 사이에 끼울 추가 줄 (예: 알림 날짜)
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
  late final _nameController = TextEditingController(
    text: widget.initialName ?? '',
  );
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

/// 그립 교체 입력 바텀시트 — 저장하면 _GripChange를 돌려준다
class _GripChangeSheet extends StatefulWidget {
  const _GripChangeSheet({
    required this.initialName,
    required this.initialType,
  });

  /// 현재 그립 — 같은 그립으로 교체하는 경우가 많아 미리 채워둔다. 없으면 빈칸
  final String? initialName;
  final String? initialType;

  @override
  State<_GripChangeSheet> createState() => _GripChangeSheetState();
}

class _GripChangeSheetState extends State<_GripChangeSheet> {
  late final _nameController = TextEditingController(
    text: widget.initialName ?? '',
  );
  late String? _type = widget.initialType;

  /// 교체일 — 기본은 오늘
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
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
    final type = _type;
    if (name.isEmpty || type == null) return;
    Navigator.pop(context, _GripChange(name: name, type: type, date: _date));
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
            '그립 교체',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          _SheetLabel('그립명'),
          AppTextField(hint: '입력', controller: _nameController),
          const SizedBox(height: 16),
          _SheetLabel('그립 종류'),
          DropdownButtonFormField<String>(
            // key를 value로 두면 값이 바뀔 때 위젯을 새로 만들어 초기값이 반영된다
            key: ValueKey(_type),
            initialValue: _type,
            isExpanded: true,
            hint: const Text('선택', style: TextStyle(color: _gray)),
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
              for (final entry in _gripTypes.entries)
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            ],
            onChanged: (value) => setState(() => _type = value),
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
