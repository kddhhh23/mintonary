import 'package:flutter/material.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _lightNavy = Color(0xFFE9EEF8);

/// 라켓 상세 화면
class RacketDetailScreen extends StatefulWidget {
  const RacketDetailScreen({super.key, required this.name});

  final String name;

  @override
  State<RacketDetailScreen> createState() => _RacketDetailScreenState();
}

class _RacketDetailScreenState extends State<RacketDetailScreen> {
  /// 스트링 교체 주기(일) — 임시값. 서버 연동 시 my_racket에서 읽어온다
  int _stringCycleDays = 30;

  /// 마지막 스트링 교체일 — 임시값
  final _strungAt = DateTime(2026, 7, 22);

  /// 다음 교체 예정일 = 마지막 교체일 + 주기
  DateTime get _nextStringDate =>
      _strungAt.add(Duration(days: _stringCycleDays));

  /// 다이얼로그로 주기(일)를 입력받는다
  Future<void> _editStringCycle() async {
    final controller = TextEditingController(text: '$_stringCycleDays');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('스트링 교체 주기'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: '일'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            style: FilledButton.styleFrom(backgroundColor: _navy),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      setState(() => _stringCycleDays = result); // TODO: 서버에 저장
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
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
                    const Row(
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
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. 스펙 (racket_model)
              const _Card(
                child: Row(
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
              ),

              const SizedBox(height: 28),

              // 3. 현재 스트링
              const _SectionTitle('스트링'),
              const SizedBox(height: 12),
              _CurrentCard(
                icon: Icons.linear_scale,
                title: 'BG80 · 26lbs',
                sub: '${_formatDate(_strungAt)} 교체 · 27일째',
                badge: 'D-3',
                badgeColor: const Color(0xFFD9433C),
                badgeBg: const Color(0xFFFCE8E7),
                // 교체 주기 · 다음 교체일 · 변경 버튼
                extra: Row(
                  children: [
                    const Icon(Icons.autorenew, size: 16, color: _gray),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '교체 주기 $_stringCycleDays일 · 다음 교체 ${_formatDate(_nextStringDate)}',
                        style: const TextStyle(fontSize: 13, color: _gray),
                      ),
                    ),
                    GestureDetector(
                      onTap: _editStringCycle,
                      child: const Text(
                        '변경',
                        style: TextStyle(
                          fontSize: 13,
                          color: _navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                actionLabel: '스트링 교체',
                onAction: () {}, // TODO: 스트링 교체 입력
              ),
              const SizedBox(height: 12),
              // 스트링 교체 이력 — 최신순
              const _HistoryCard(
                count: 3,
                rows: [
                  _HistoryRow(date: '2026.07.22', detail: 'BG80 · 26lbs'),
                  _HistoryRow(date: '2026.06.30', detail: 'BG80 · 26lbs'),
                  _HistoryRow(date: '2025.11.02', detail: 'BG65 · 25lbs'),
                ],
              ),

              const SizedBox(height: 28),

              // 4. 현재 그립
              const _SectionTitle('그립'),
              const SizedBox(height: 12),
              _CurrentCard(
                icon: Icons.gesture,
                title: '슈퍼그랩 · 오버그립',
                sub: '2026.08.05 교체 · 13일째',
                badge: '양호',
                badgeColor: _navy,
                badgeBg: _lightNavy,
                actionLabel: '그립 교체',
                onAction: () {}, // TODO: 그립 교체 입력
              ),
              const SizedBox(height: 12),
              // 그립 교체 이력 — 최신순
              const _HistoryCard(
                count: 2,
                rows: [
                  _HistoryRow(date: '2026.08.05', detail: '슈퍼그랩 · 오버그립'),
                  _HistoryRow(date: '2026.06.01', detail: '슈퍼그랩 · 오버그립'),
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
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    required this.actionLabel,
    required this.onAction,
    this.extra,
  });

  final IconData icon;
  final String title;
  final String sub;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
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
              _Badge(text: badge, color: badgeColor, bg: badgeBg),
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

/// 교체 이력 한 줄 — 날짜 · 내용
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.date, required this.detail});

  final String date;
  final String detail;

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
      ],
    );
  }
}
