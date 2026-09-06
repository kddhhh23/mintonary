import 'package:flutter/material.dart';

import '../data/app_repositories.dart';
import '../models/equipment.dart';
import '../models/expense.dart';
import '../models/workout_record.dart';
import '../services/session.dart';
import 'equipment_screen.dart';
import 'expense_screen.dart';
import 'profile_setup_screen.dart';
import 'racket_detail_screen.dart';
import 'record_screen.dart';
import 'shoe_detail_screen.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _lightNavy = Color(0xFFE9EEF8); // 아이콘 배경
const _activeDay = Color(0xFFD5DEF5); // 운동한 날 점
const _today = Color(0xFF5EEAD4); // 오늘 날짜 강조 (민트)

/// 홈 화면 (하단 탭 포함)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// 현재 탭 — 0 홈, 1 기록, 2 장비, 3 지출
  int _tab = 0;

  void _goTab(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_tab) {
          0 => _HomeBody(onGoTab: _goTab),
          1 => const RecordScreen(),
          2 => const EquipmentScreen(),
          _ => const ExpenseScreen(),
        },
      ),
      bottomNavigationBar: _BottomBar(current: _tab, onTap: _goTab),
    );
  }
}

/// 홈 탭 내용 — 운동 기록과 장비를 서버에서 함께 불러온다
class _HomeBody extends StatefulWidget {
  const _HomeBody({required this.onGoTab});

  /// "전체보기" 눌렀을 때 탭을 바꾸기 위한 콜백
  final ValueChanged<int> onGoTab;

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final now = DateTime.now();
    final results = await Future.wait<Object>([
      AppRepositories.records.fetchRecordMonth(now.year, now.month),
      AppRepositories.equipment.fetchEquipments(),
      AppRepositories.expenses.fetchExpenseMonth(now.year, now.month),
    ]);
    return _HomeData(
      records: results[0] as List<WorkoutRecord>,
      equipments: results[1] as EquipmentList,
      expenses: results[2] as ExpenseMonth,
    );
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _editProfile() async {
    final profile = await AppRepositories.profile.load();
    if (!mounted || profile == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(initialProfile: profile),
      ),
    );
    if (saved == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            nickname: Session.nickname ?? '회원',
            onProfileTap: _editProfile,
          ),
          const SizedBox(height: 24),
          FutureBuilder<_HomeData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _HomeError(
                  message: snapshot.error.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
                  onRetry: _reload,
                );
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: CircularProgressIndicator(color: _navy)),
                );
              }
              return _HomeContent(
                data: snapshot.data!,
                onGoTab: widget.onGoTab,
                onRefresh: _reload,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.records,
    required this.equipments,
    required this.expenses,
  });

  final List<WorkoutRecord> records;
  final EquipmentList equipments;
  final ExpenseMonth expenses;
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.onGoTab,
    required this.onRefresh,
  });

  final _HomeData data;
  final ValueChanged<int> onGoTab;
  final VoidCallback onRefresh;

  String _racketSub(RacketSummary racket) {
    if (racket.stringName == null) return '스트링 기록 없음';
    final tension = racket.tension == null ? '' : ' · ${racket.tension}lbs';
    final elapsed = racket.strungAt == null
        ? ''
        : ' · ${DateTime.now().difference(racket.strungAt!).inDays}일째';
    return '스트링 ${racket.stringName}$tension$elapsed';
  }

  String _shoeSub(ShoeSummary shoe) {
    if (shoe.purchaseDate == null) return '구매일 미입력';
    final date = shoe.purchaseDate!;
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} 구매';
  }

  Future<void> _openRacket(BuildContext context, RacketSummary racket) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RacketDetailScreen(equipmentId: racket.id),
      ),
    );
    onRefresh();
  }

  Future<void> _openShoe(BuildContext context, ShoeSummary shoe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShoeDetailScreen(equipmentId: shoe.id)),
    );
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final rackets = data.equipments.rackets
        .where((racket) => racket.inUse)
        .take(3)
        .toList();
    final shoes = data.equipments.shoes
        .where((shoe) => shoe.inUse)
        .take(2)
        .toList();
    final hasEquipment = rackets.isNotEmpty || shoes.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MonthlyCard(records: data.records),
        const SizedBox(height: 32),
        _SectionTitle(
          title: '내 장비',
          action: '전체보기',
          onAction: () => onGoTab(2),
        ),
        const SizedBox(height: 12),
        if (!hasEquipment)
          const _EmptyCard(message: '등록된 장비가 없어요')
        else ...[
          if (rackets.isNotEmpty)
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: rackets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final racket = rackets[index];
                  return _GearCard(
                    icon: Icons.sports_tennis_outlined,
                    name: '${racket.brand} ${racket.name}',
                    sub: _racketSub(racket),
                    width: 340,
                    onTap: () => _openRacket(context, racket),
                  );
                },
              ),
            ),
          if (rackets.isNotEmpty && shoes.isNotEmpty)
            const SizedBox(height: 12),
          for (final shoe in shoes) ...[
            _GearCard(
              icon: Icons.ice_skating_outlined,
              name: '${shoe.brand} ${shoe.name}',
              sub: _shoeSub(shoe),
              onTap: () => _openShoe(context, shoe),
            ),
            if (shoe != shoes.last) const SizedBox(height: 12),
          ],
        ],
        const SizedBox(height: 28),
        _SectionTitle(
          title: '이번 달 지출',
          action: '전체보기',
          onAction: () => onGoTab(3),
        ),
        const SizedBox(height: 12),
        _ExpenseHomeCard(month: data.expenses, onTap: () => onGoTab(3)),
      ],
    );
  }
}

/// 상단: 날짜 + 인사말 + 프로필
class _Header extends StatelessWidget {
  const _Header({required this.nickname, this.onProfileTap});

  final String nickname;
  final VoidCallback? onProfileTap;

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${now.month}월 ${now.day}일 ${_weekdays[now.weekday - 1]}요일';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontSize: 14, color: _gray)),
              const SizedBox(height: 4),
              Text(
                '$nickname님, 오늘도 코트로!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          button: onProfileTap != null,
          label: '내 정보 수정',
          child: InkWell(
            onTap: onProfileTap,
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: _navy,
              child: Text(
                nickname.isEmpty ? '회' : nickname.characters.first,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 이번 달 운동 횟수 카드
class _MonthlyCard extends StatelessWidget {
  const _MonthlyCard({required this.records});

  final List<WorkoutRecord> records;

  static const _cell = 18.0; // 달력 한 칸 자리 (점 13 + 여백)

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final worked = records.map((record) => record.date.day).toSet();
    // 다음 달 0일 = 이번 달 마지막 날
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstOffset =
        DateTime(now.year, now.month, 1).weekday % 7; // 1일이 일요일이면 0
    final weeks = ((firstOffset + daysInMonth) / 7)
        .ceil(); // 이번 달이 걸치는 주 수 = 줄 수

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(22),
      ),
      // 왼쪽: 제목 + 큰 숫자, 오른쪽: 달력 (가로 = 월~일, 세로 = 주)
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이번 달 운동',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${records.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const TextSpan(
                        text: ' 회',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 몇 월인지
              Padding(
                padding: const EdgeInsets.only(left: 3, bottom: 4),
                child: Text(
                  '${now.month}월',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // 날짜 격자 — 한 줄이 한 주, 왼쪽부터 월~일
              for (var w = 0; w < weeks; w++)
                Row(
                  children: List.generate(7, (c) {
                    // 이 칸의 날짜 (범위 밖이면 빈 칸)
                    final day = w * 7 + c - firstOffset + 1;
                    return SizedBox(
                      width: _cell,
                      height: _cell,
                      child: day < 1 || day > daysInMonth
                          ? null
                          : Center(
                              child: _DayCell(
                                worked: worked.contains(day),
                                isToday: day == now.day,
                                isFuture: day > now.day,
                              ),
                            ),
                    );
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 달력의 하루 칸
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.worked,
    required this.isToday,
    required this.isFuture,
  });

  final bool worked;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: isToday
            ? _today.withValues(alpha: worked ? 1 : 0.35) // 오늘은 민트 (운동했으면 진하게)
            : worked
            ? _activeDay
            : Colors.white.withValues(alpha: isFuture ? 0.06 : 0.14),
        borderRadius: BorderRadius.circular(4),
      ),
    );
    if (!isToday) return dot;

    // 오늘 — 점 바깥에 민트 링을 둘러 눈에 띄게
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(color: _today, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: dot,
    );
  }
}

/// 섹션 제목 (오른쪽에 "전체보기 ›" 선택)
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction; // "전체보기" 눌렀을 때

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              '$action ›',
              style: const TextStyle(fontSize: 14, color: _gray),
            ),
          ),
      ],
    );
  }
}

/// 홈 장비 카드 — 누르면 해당 장비 상세로 이동한다
class _GearCard extends StatelessWidget {
  const _GearCard({
    required this.icon,
    required this.name,
    required this.sub,
    required this.onTap,
    this.width,
  });

  final IconData icon;
  final String name;
  final String sub;
  final VoidCallback onTap;
  final double? width; // 가로 스크롤용 카드는 폭 고정

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _lightNavy,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: _navy),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: _gray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _gray),
      ),
    );
  }
}

class _ExpenseHomeCard extends StatelessWidget {
  const _ExpenseHomeCard({required this.month, required this.onTap});

  final ExpenseMonth month;
  final VoidCallback onTap;

  String _amount(int value) => value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final days = today.difference(target).inDays;
    if (days == 0) return '오늘';
    if (days == 1) return '어제';
    return '${date.month}월 ${date.day}일';
  }

  @override
  Widget build(BuildContext context) {
    final recent = month.recentExpense;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_amount(month.totalAmount)}원',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              if (recent == null)
                const Text('이번 달 지출 내역이 없어요', style: TextStyle(color: _gray))
              else
                Row(
                  children: [
                    const Text(
                      '최근',
                      style: TextStyle(
                        fontSize: 13,
                        color: _gray,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_dateLabel(recent.date)} · ${recent.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_amount(recent.amount)}원',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Center(
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
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
}

/// 하단 탭바
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.current, required this.onTap});

  final int current; // 현재 선택된 탭 번호
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    Widget item(int index, IconData icon, String label) => _BottomItem(
      icon: icon,
      label: label,
      selected: current == index,
      onTap: () => onTap(index),
    );

    return BottomAppBar(
      color: Colors.white,
      height: 72,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          item(0, Icons.home_rounded, '홈'),
          item(1, Icons.calendar_today_outlined, '기록'),
          item(2, Icons.sports_tennis_outlined, '장비'),
          item(3, Icons.account_balance_wallet_outlined, '지출'),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _navy : _gray;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
