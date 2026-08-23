import 'package:flutter/material.dart';

import '../models/equipment.dart';
import '../services/equipment_api.dart';
import 'equipment_register_screen.dart';
import 'racket_detail_screen.dart';
import 'shoe_detail_screen.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _lightNavy = Color(0xFFE9EEF8); // 아이콘 배경

/// 장비 탭 — 라켓 / 신발 목록
class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  late Future<EquipmentList> _future;

  @override
  void initState() {
    super.initState();
    _future = EquipmentApi.fetchEquipments();
  }

  void _reload() {
    setState(() => _future = EquipmentApi.fetchEquipments());
  }

  Future<void> _openRegister() async {
    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EquipmentRegisterScreen()),
    );
    if (registered == true) _reload();
  }

  /// 상세에서 상태·이력이 바뀌었을 수 있어 돌아오면 다시 불러온다
  Future<void> _openRacket(RacketSummary racket) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RacketDetailScreen(equipmentId: racket.id),
      ),
    );
    _reload();
  }

  Future<void> _openShoe(ShoeSummary shoe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShoeDetailScreen(equipmentId: shoe.id)),
    );
    _reload();
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  /// 1234567 → 1,234,567
  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  String _purchaseLabel(DateTime? date, int? price) {
    final parts = [
      if (date != null) '구매 ${_formatDate(date)}',
      if (price != null) '${_formatPrice(price)}원',
    ];
    return parts.isEmpty ? '구매 정보 없음' : parts.join(' · ');
  }

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
                onPressed: _openRegister,
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

          FutureBuilder<EquipmentList>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _ErrorBox(
                  message: snapshot.error.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
                  onRetry: _reload,
                );
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator(color: _navy)),
                );
              }

              final list = snapshot.data!;
              if (list.rackets.isEmpty && list.shoes.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      '등록된 장비가 없어요\n오른쪽 위 버튼으로 장비를 등록해 보세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _gray, height: 1.6),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (list.rackets.isNotEmpty) ...[
                    _SectionLabel(title: '라켓', count: list.rackets.length),
                    const SizedBox(height: 12),
                    for (final racket in list.rackets) ...[
                      _RacketCard(
                        name: '${racket.brand} ${racket.name}',
                        purchase: _purchaseLabel(
                          racket.purchaseDate,
                          racket.price,
                        ),
                        inUse: racket.inUse,
                        string: racket.stringName == null
                            ? '기록 없음'
                            : '${racket.stringName}${racket.tension == null ? '' : ' · ${racket.tension}lbs'}',
                        stringDate: racket.strungAt == null
                            ? ''
                            : '${_formatDate(racket.strungAt!)} 교체',
                        grip: racket.gripName ?? '기록 없음',
                        gripDate: racket.wrappedAt == null
                            ? ''
                            : '${_formatDate(racket.wrappedAt!)} 교체',
                        onTap: () => _openRacket(racket),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 16),
                  ],
                  if (list.shoes.isNotEmpty) ...[
                    _SectionLabel(title: '신발', count: list.shoes.length),
                    const SizedBox(height: 12),
                    for (final shoe in list.shoes) ...[
                      _ShoeCard(
                        name: '${shoe.brand} ${shoe.name}',
                        purchase: _purchaseLabel(shoe.purchaseDate, shoe.price),
                        inUse: shoe.inUse,
                        onTap: () => _openShoe(shoe),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 목록을 못 불러왔을 때 — 메시지 + 다시 시도
class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Text(message, style: const TextStyle(color: _gray)),
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

/// 라켓 카드 — 기본 정보 + 현재 스트링/그립
class _RacketCard extends StatelessWidget {
  const _RacketCard({
    required this.name,
    required this.purchase,
    required this.inUse,
    required this.string,
    required this.stringDate,
    required this.grip,
    required this.gripDate,
    required this.onTap,
  });

  final String name;
  final String purchase;
  final bool inUse;
  final String string;
  final String stringDate;
  final String grip;
  final String gripDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
              inUse: inUse,
            ),
            const SizedBox(height: 22),
            // 스트링 / 그립 — 2열, 각각 아래에 교체일
            Row(
              children: [
                Expanded(
                  child: _Stat(label: '스트링', value: string, date: stringDate),
                ),
                const SizedBox(width: 20), // 두 열 사이 간격 — 선이 끊긴다
                Expanded(
                  child: _Stat(label: '그립', value: grip, date: gripDate),
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
    required this.inUse,
    required this.onTap,
  });

  final String name;
  final String purchase;
  final bool inUse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: _GearHeader(
          icon: Icons.ice_skating_outlined,
          name: name,
          sub: purchase,
          inUse: inUse,
        ),
      ),
    );
  }
}

/// 카드 윗줄 — 아이콘 · 이름 · 설명 · 사용 상태 태그 (라켓/신발 공통)
class _GearHeader extends StatelessWidget {
  const _GearHeader({
    required this.icon,
    required this.name,
    required this.sub,
    required this.inUse,
  });

  final IconData icon;
  final String name;
  final String sub;
  final bool inUse;

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: inUse ? _lightNavy : const Color(0xFFF1F3F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            inUse ? '사용 중' : '미사용',
            style: TextStyle(
              color: inUse ? _navy : _gray,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// 라벨(회색) 위, 값(굵게), 그 아래 교체일(작은 회색)
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.date});

  final String label;
  final String value;

  /// 이미 만들어진 문구 (예: "2026.07.22 교체"). 비어 있으면 표시하지 않는다
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 소제목처럼 — 진하게 + 아래 얇은 선
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 10),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        if (date.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 13, color: _gray)),
        ],
      ],
    );
  }
}
