import 'package:flutter/material.dart';

import 'equipment_screen.dart';

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
  static const _tabNames = ['홈', '기록', '장비', '지출'];

  /// 현재 탭 — 0 홈, 1 기록, 2 장비, 3 지출
  int _tab = 0;

  void _goTab(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_tab) {
          0 => _HomeBody(onGoTab: _goTab),
          2 => const EquipmentScreen(),
          // TODO: 기록 / 지출 화면 만들면 교체
          _ => Center(
            child: Text(
              '${_tabNames[_tab]} 화면 준비 중',
              style: const TextStyle(color: _gray),
            ),
          ),
        },
      ),
      bottomNavigationBar: _BottomBar(current: _tab, onTap: _goTab),
    );
  }
}

/// 홈 탭 내용
class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.onGoTab});

  /// "전체보기" 눌렀을 때 탭을 바꾸기 위한 콜백
  final ValueChanged<int> onGoTab;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const SizedBox(height: 24),
          const _MonthlyCard(),
          const SizedBox(height: 32),

          // 내 장비
          _SectionTitle(
            title: '내 장비',
            action: '전체보기',
            onAction: () => onGoTab(2),
          ),
          const SizedBox(height: 12),
          // 라켓 목록 — 가로 스크롤
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: const [
                _GearCard(
                  icon: Icons.sports_tennis_outlined,
                  name: '요넥스 아스트록스 99',
                  sub: '스트링 BG80 · 27일째',
                  badge: '스트링 D-3',
                  badgeColor: Color(0xFFD9433C),
                  badgeBg: Color(0xFFFCE8E7),
                  width: 340,
                ),
                SizedBox(width: 12),
                _GearCard(
                  icon: Icons.sports_tennis_outlined,
                  name: '빅터 스러스터 K',
                  sub: '스트링 BG65 · 12일째',
                  badge: '양호',
                  badgeColor: _navy,
                  badgeBg: _lightNavy,
                  width: 340,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _GearCard(
            icon: Icons.ice_skating_outlined,
            name: '리닝 레인저 TD',
            sub: '착용 8개월 · 주 3회 사용',
            badge: '양호',
            badgeColor: _navy,
            badgeBg: _lightNavy,
          ),

          const SizedBox(height: 28),

          // 지출
          _SectionTitle(
            title: '이번 달 지출',
            action: '전체보기',
            onAction: () => onGoTab(3),
          ),
          const SizedBox(height: 12),
          const _ExpenseCard(
            total: '128,000원',
            recent: '어제 · 셔틀콕 1통',
            recentAmount: '18,000원',
          ),
        ],
      ),
    );
  }
}

/// 상단: 날짜 + 인사말 + 프로필
class _Header extends StatelessWidget {
  const _Header();

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
              const Text(
                '지수님, 오늘도 코트로!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 24,
          backgroundColor: _navy,
          child: Text(
            '지',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// 이번 달 운동 횟수 카드
class _MonthlyCard extends StatelessWidget {
  const _MonthlyCard();

  static const _cell = 18.0; // 달력 한 칸 자리 (점 13 + 여백)

  /// 이번 달 운동한 날짜(일) — 임시 데이터
  static const _worked = {1, 3, 4, 6, 8, 10, 11, 13, 15, 17, 18, 20, 22, 25};

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // 다음 달 0일 = 이번 달 마지막 날
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstOffset =
        DateTime(now.year, now.month, 1).weekday - 1; // 1일이 월요일이면 0
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이번 달 운동',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '14',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      TextSpan(
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
                                worked: _worked.contains(day),
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

/// 장비 카드 (아이콘 · 이름 · 설명 · 상태 배지)
class _GearCard extends StatelessWidget {
  const _GearCard({
    required this.icon,
    required this.name,
    required this.sub,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    this.width,
  });

  final IconData icon;
  final String name;
  final String sub;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
  final double? width; // 가로 스크롤용 카드는 폭 고정

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
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
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: badgeColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 지출 카드 — 이번 달 합계 + 최근 지출 1건
class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.total,
    required this.recent,
    required this.recentAmount,
  });

  final String total; // 이번 달 합계
  final String recent; // 최근 지출 설명 (언제 · 무엇)
  final String recentAmount; // 최근 지출 금액

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            total,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // 최근 지출 한 줄
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
                  recent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                recentAmount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 하단 탭바 (가운데 + 버튼)
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
          const _AddButton(),
          item(2, Icons.sports_tennis_outlined, '장비'),
          item(3, Icons.account_balance_wallet_outlined, '지출'),
        ],
      ),
    );
  }
}

/// 가운데 + 버튼 — 바 안에 두고 살짝만 위로 올린다
class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -12), // 위로 12만큼 (레이아웃엔 영향 없음)
          child: SizedBox(
            width: 60,
            height: 60,
            child: FilledButton(
              onPressed: () {}, // TODO: 기록 추가 화면 이동
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ),
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
