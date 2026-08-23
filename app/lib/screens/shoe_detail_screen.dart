import 'package:flutter/material.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _lightNavy = Color(0xFFE9EEF8);
const _bg = Color(0xFFF1F3F8);

/// 신발 상세 화면
class ShoeDetailScreen extends StatefulWidget {
  const ShoeDetailScreen({super.key, required this.name});

  final String name;

  @override
  State<ShoeDetailScreen> createState() => _ShoeDetailScreenState();
}

class _ShoeDetailScreenState extends State<ShoeDetailScreen> {
  /// 사용 상태 — 임시값. 서버 연동 시 equipment.retiredAt이 null인지로 판단한다
  bool _inUse = true;

  /// 바텀시트로 사용 상태를 고른다
  Future<void> _editStatus() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _StatusSheet(inUse: _inUse),
    );
    if (result != null) {
      setState(() => _inUse = result); // TODO: 서버에 저장
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
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
                        // 사용 상태 태그 — 누르면 변경
                        GestureDetector(
                          onTap: _editStatus,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _inUse ? _lightNavy : _bg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _inUse ? '사용 중' : '미사용',
                              style: TextStyle(
                                color: _inUse ? _navy : _gray,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
