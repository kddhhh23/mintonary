import 'package:flutter/material.dart';

import '../data/app_repositories.dart';
import '../data/repositories.dart';
import '../models/equipment.dart';
import 'equipment_edit_screen.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _lightNavy = Color(0xFFE9EEF8);
const _bg = Color(0xFFF1F3F8);
const _red = Color(0xFFD9433C);

enum _EquipmentAction { edit, delete }

/// 신발 상세 화면
class ShoeDetailScreen extends StatefulWidget {
  const ShoeDetailScreen({super.key, required this.equipmentId});

  final int equipmentId;

  @override
  State<ShoeDetailScreen> createState() => _ShoeDetailScreenState();
}

class _ShoeDetailScreenState extends State<ShoeDetailScreen> {
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
    );
  }

  Future<void> _editEquipment() async {
    final detail = _detail;
    if (detail == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EquipmentEditScreen(detail: detail)),
    );
    if (saved == true) await _load();
  }

  Future<void> _deleteEquipment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신발 삭제'),
        content: const Text('신발 정보가 완전히 삭제됩니다.\n이미 추가된 지출 내역은 유지됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
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
    if (confirmed != true) return;
    try {
      await AppRepositories.equipment.deleteEquipment(widget.equipmentId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  void _handleAction(_EquipmentAction action) {
    switch (action) {
      case _EquipmentAction.edit:
        _editEquipment();
      case _EquipmentAction.delete:
        _deleteEquipment();
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  /// 1234567 → 1,234,567
  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  /// 구매일부터 지금까지 몇 개월 신었는지
  String _usageLabel(DateTime? purchaseDate) {
    if (purchaseDate == null) return '-';
    final now = DateTime.now();
    var months =
        (now.year - purchaseDate.year) * 12 + now.month - purchaseDate.month;
    if (now.day < purchaseDate.day) months--;
    return months < 1 ? '1개월 미만' : '$months개월';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신발 상세'),
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<_EquipmentAction>(
            enabled: _detail != null,
            onSelected: _handleAction,
            itemBuilder: (context) => [
              if (storageMode == StorageMode.local)
                const PopupMenuItem(
                  value: _EquipmentAction.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('수정'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: _EquipmentAction.delete,
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: _red),
                  title: Text('삭제', style: TextStyle(color: _red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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
    final shoe = detail?.shoe;
    if (detail == null || shoe == null) {
      return const Center(child: CircularProgressIndicator(color: _navy));
    }

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
                            '${shoe.brand} ${shoe.name}',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shoe.brand,
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
                // 스펙 (shoe_model)
                Row(
                  children: [
                    Expanded(
                      child: _Stat(label: '발볼', value: shoe.width ?? '-'),
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
                    label: '착용',
                    value: _usageLabel(detail.purchaseDate),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 3. 메모
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
