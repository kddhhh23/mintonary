import 'package:flutter/material.dart';

import '../data/app_repositories.dart';
import '../models/equipment.dart';
import '../widgets/app_text_field.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _hint = Color(0xFFA8B0BF);

typedef _ModelOption = ({int id, String brand, String name});

class EquipmentEditScreen extends StatefulWidget {
  const EquipmentEditScreen({super.key, required this.detail});

  final EquipmentDetail detail;

  @override
  State<EquipmentEditScreen> createState() => _EquipmentEditScreenState();
}

class _EquipmentEditScreenState extends State<EquipmentEditScreen> {
  List<_ModelOption>? _options;
  String? _brand;
  String? _model;
  bool _directInput = false;
  final _customBrandController = TextEditingController();
  final _customModelController = TextEditingController();
  DateTime? _purchaseDate;
  final _priceController = TextEditingController();
  final _memoController = TextEditingController();
  String? _loadError;
  bool _submitting = false;

  bool get _isRacket => widget.detail.type == 'RACKET';

  Map<String, List<_ModelOption>> get _byBrand {
    final result = <String, List<_ModelOption>>{};
    for (final option in _options ?? const <_ModelOption>[]) {
      result.putIfAbsent(option.brand, () => []).add(option);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    final info = _isRacket ? widget.detail.racket : widget.detail.shoe;
    if (info is RacketInfo) {
      _brand = info.brand;
      _model = info.name;
    } else if (info is ShoeInfo) {
      _brand = info.brand;
      _model = info.name;
    }
    _purchaseDate = widget.detail.purchaseDate;
    _priceController.text = widget.detail.price?.toString() ?? '';
    _memoController.text = widget.detail.memo ?? '';
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      final List<_ModelOption> options;
      if (_isRacket) {
        final models = await AppRepositories.equipment.fetchRacketModels();
        options = models
            .map((item) => (id: item.id, brand: item.brand, name: item.name))
            .toList();
      } else {
        final models = await AppRepositories.equipment.fetchShoeModels();
        options = models
            .map((item) => (id: item.id, brand: item.brand, name: item.name))
            .toList();
      }
      if (!mounted) return;
      setState(() {
        _options = options;
        _loadError = null;
        final currentExists = _options!.any(
          (item) => item.brand == _brand && item.name == _model,
        );
        if (!currentExists) {
          _brand = null;
          _model = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void dispose() {
    _customBrandController.dispose();
    _customModelController.dispose();
    _priceController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final brand = _brand;
    final model = _model;
    final customBrand = _customBrandController.text.trim();
    final customModel = _customModelController.text.trim();
    if (_directInput && (customBrand.isEmpty || customModel.isEmpty)) {
      _showMessage('브랜드와 모델명을 입력해 주세요.');
      return;
    }
    if (!_directInput && (brand == null || model == null)) {
      _showMessage('브랜드와 모델을 선택해 주세요.');
      return;
    }
    final priceText = _priceController.text.trim();
    final price = priceText.isEmpty ? null : int.tryParse(priceText);
    if (priceText.isNotEmpty && (price == null || price <= 0)) {
      _showMessage('가격은 0원보다 큰 숫자로 입력해 주세요.');
      return;
    }
    if (price != null && price > 2147483647) {
      _showMessage('가격이 너무 큽니다.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final int modelId;
      if (_directInput) {
        modelId = await AppRepositories.equipment.addCustomModel(
          type: widget.detail.type,
          brand: customBrand,
          name: customModel,
        );
      } else {
        modelId = _byBrand[brand]!
            .firstWhere((option) => option.name == model)
            .id;
      }
      await AppRepositories.equipment.updateEquipment(
        widget.detail.id,
        modelId: modelId,
        purchaseDate: _purchaseDate,
        price: price,
        memo: _memoController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
      setState(() => _submitting = false);
    }
  }

  String _dateLabel(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRacket ? '라켓 수정' : '신발 수정'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_loadError!, style: const TextStyle(color: _gray)),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadModels, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    if (_options == null) {
      return const Center(child: CircularProgressIndicator(color: _navy));
    }

    final models = _byBrand;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _InputModeButton(
                  label: '목록에서 선택',
                  selected: !_directInput,
                  onTap: () => setState(() => _directInput = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputModeButton(
                  label: '직접 입력',
                  selected: _directInput,
                  onTap: () => setState(() => _directInput = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_directInput) ...[
            _Labeled(
              label: '브랜드',
              child: AppTextField(
                hint: '예: 미즈노',
                controller: _customBrandController,
                maxLength: 50,
              ),
            ),
            const SizedBox(height: 16),
            _Labeled(
              label: _isRacket ? '라켓명' : '신발명',
              child: AppTextField(
                hint: '모델명 입력',
                controller: _customModelController,
                maxLength: 100,
              ),
            ),
          ] else ...[
            _Labeled(
              label: '브랜드',
              child: _Dropdown(
                value: _brand,
                items: models.keys.toList(),
                onChanged: (value) => setState(() {
                  _brand = value;
                  _model = null;
                }),
              ),
            ),
            const SizedBox(height: 16),
            _Labeled(
              label: _isRacket ? '라켓명' : '신발명',
              child: _Dropdown(
                value: _model,
                items: _brand == null
                    ? const []
                    : models[_brand]!.map((item) => item.name).toList(),
                onChanged: (value) => setState(() => _model = value),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _Labeled(
            label: '구매일',
            child: Row(
              children: [
                Expanded(
                  child: _PickerBox(
                    label: _purchaseDate == null
                        ? '선택'
                        : _dateLabel(_purchaseDate!),
                    selected: _purchaseDate != null,
                    onTap: _pickPurchaseDate,
                  ),
                ),
                if (_purchaseDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: '구매일 지우기',
                    onPressed: () => setState(() => _purchaseDate = null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Labeled(
            label: '가격',
            child: AppTextField(
              hint: '원',
              controller: _priceController,
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 16),
          _Labeled(
            label: '메모',
            child: TextField(
              controller: _memoController,
              minLines: 3,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: '선택 입력',
                hintStyle: const TextStyle(color: _hint),
                filled: true,
                fillColor: Colors.white,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _navy,
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '저장하기',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: _gray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child,
    ],
  );
}

class _InputModeButton extends StatelessWidget {
  const _InputModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? _navy : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? Colors.white : _hint,
        ),
      ),
    ),
  );
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    key: ValueKey(value),
    initialValue: value,
    isExpanded: true,
    hint: const Text('선택', style: TextStyle(color: _hint)),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    items: items
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList(),
    onChanged: onChanged,
  );
}

class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
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
          Text(label, style: TextStyle(color: selected ? null : _hint)),
          const Spacer(),
          const Icon(Icons.calendar_today_outlined, size: 20, color: _gray),
        ],
      ),
    ),
  );
}
