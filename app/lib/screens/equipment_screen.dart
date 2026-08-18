import 'package:flutter/material.dart';

import 'equipment_register_screen.dart';
import 'racket_detail_screen.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _lightNavy = Color(0xFFE9EEF8); // 아이콘 배경

/// 장비 탭 — 라켓 / 신발 목록
class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 등록 버튼
          Row(
            children: [
              const Expanded(
                child: Text(
                  '내 장비',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EquipmentRegisterScreen(),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  '+ 장비 등록',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 라켓
          const _SectionLabel(title: '라켓', count: 3),
          const SizedBox(height: 12),
          const _RacketCard(
            name: '요넥스 아스트록스 99',
            purchase: '구매 2025.11.02 · 320,000원',
            badge: '스트링 D-3',
            badgeColor: Color(0xFFD9433C),
            badgeBg: Color(0xFFFCE8E7),
            string: 'BG80 · 26lbs',
            grip: '슈퍼그랩',
            history: '5회',
          ),
          const SizedBox(height: 12),
          const _RacketCard(
            name: '빅터 썬더 TK-F',
            purchase: '구매 2025.06.10 · 218,000원',
            badge: '양호',
            badgeColor: _navy,
            badgeBg: _lightNavy,
            string: 'VBS-66N · 27lbs',
            grip: '카모 그립',
            history: '3회',
          ),
          const SizedBox(height: 12),
          const _RacketCard(
            name: '리닝 에어로너트 9000',
            purchase: '구매 2024.09.21 · 265,000원',
            badge: '교체 D-9',
            badgeColor: Color(0xFFB07A1A),
            badgeBg: Color(0xFFFBF1DA),
            string: 'No.1 · 25lbs',
            grip: '타월그립',
            history: '7회',
          ),
          const SizedBox(height: 28),

          // 신발
          const _SectionLabel(title: '신발', count: 1),
          const SizedBox(height: 12),
          const _ShoeCard(
            name: '리닝 레인저 TD',
            purchase: '구매 2025.11.15 · 89,000원 · 착용 8개월',
            badge: '양호',
            badgeColor: _navy,
            badgeBg: _lightNavy,
          ),
        ],
      ),
    );
  }
}

/// 섹션 라벨 — "라켓 3" 처럼 이름 + 개수
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        children: [
          TextSpan(text: title),
          TextSpan(
            text: ' $count',
            style: const TextStyle(color: _gray),
          ),
        ],
      ),
    );
  }
}

/// 라켓 카드 — 기본 정보 + 스트링/그립/교체 이력
class _RacketCard extends StatelessWidget {
  const _RacketCard({
    required this.name,
    required this.purchase,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    required this.string,
    required this.grip,
    required this.history,
  });

  final String name;
  final String purchase;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
  final String string;
  final String grip;
  final String history;

  @override
  Widget build(BuildContext context) {
    // 카드를 누르면 상세 화면으로
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RacketDetailScreen(name: name)),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GearHeader(
              icon: Icons.sports_tennis_outlined,
              name: name,
              sub: purchase,
              badge: badge,
              badgeColor: badgeColor,
              badgeBg: badgeBg,
            ),
            const SizedBox(height: 22),
            // 스트링 / 그립 / 교체 이력 — 3열
            Row(
              children: [
                Expanded(
                  child: _Stat(label: '스트링', value: string),
                ),
                Expanded(
                  child: _Stat(label: '그립', value: grip),
                ),
                Expanded(
                  child: _Stat(label: '교체 이력', value: history),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 신발 카드 — 기본 정보만
class _ShoeCard extends StatelessWidget {
  const _ShoeCard({
    required this.name,
    required this.purchase,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
  });

  final String name;
  final String purchase;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: _GearHeader(
        icon: Icons.ice_skating_outlined,
        name: name,
        sub: purchase,
        badge: badge,
        badgeColor: badgeColor,
        badgeBg: badgeBg,
      ),
    );
  }
}

/// 카드 윗줄 — 아이콘 · 이름 · 설명 · 상태 배지 (라켓/신발 공통)
class _GearHeader extends StatelessWidget {
  const _GearHeader({
    required this.icon,
    required this.name,
    required this.sub,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
  });

  final IconData icon;
  final String name;
  final String sub;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              Text(sub, style: const TextStyle(fontSize: 13, color: _gray)),
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
