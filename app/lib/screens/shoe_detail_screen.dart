import 'package:flutter/material.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _lightNavy = Color(0xFFE9EEF8);

/// 신발 상세 화면
class ShoeDetailScreen extends StatelessWidget {
  const ShoeDetailScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신발 상세'),
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
              // 1. 기본 정보 + 스펙
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
                            Icons.ice_skating_outlined,
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
                                '리닝 · 레인저',
                                style: TextStyle(fontSize: 13, color: _gray),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 스펙 (shoe_model)
                    const Row(
                      children: [
                        Expanded(
                          child: _Stat(label: '발볼', value: '2E'),
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
                      child: _Stat(label: '구매일', value: '2025.11.15'),
                    ),
                    Expanded(
                      child: _Stat(label: '가격', value: '89,000원'),
                    ),
                    Expanded(
                      child: _Stat(label: '착용', value: '8개월'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 3. 메모
              const _SectionTitle('메모'),
              const SizedBox(height: 12),
              const _Card(
                child: Text(
                  '실내 코트 전용. 쿠션 좋음.',
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
