import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/expense.dart';
import '../services/expense_api.dart';
import '../widgets/app_text_field.dart';

const _navy = Color(0xFF3D5379);
const _gray = Color(0xFF9AA3B2);
const _lightNavy = Color(0xFFE9EEF8);
const _red = Color(0xFFD9433C);

String _formatAmount(int amount) => amount.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);

String _formatDate(DateTime date) =>
    '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late DateTime _month;
  ExpenseMonth? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _load();
  }

  Future<void> _load() async {
    final requestedMonth = _month;
    setState(() {
      _data = null;
      _error = null;
    });
    try {
      final data = await ExpenseApi.fetchMonth(
        requestedMonth.year,
        requestedMonth.month,
      );
      if (!mounted || requestedMonth != _month) return;
      setState(() => _data = data);
    } catch (error) {
      if (!mounted || requestedMonth != _month) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _moveMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
    _load();
  }

  Future<void> _openForm([ExpenseItem? expense]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseFormScreen(
          expense: expense,
          initialDate: expense?.date ?? _initialDateForMonth(),
        ),
      ),
    );
    if (saved == true) await _load();
  }

  DateTime _initialDateForMonth() {
    final now = DateTime.now();
    if (_month.year == now.year && _month.month == now.month) return now;
    final lastDay = DateTime(_month.year, _month.month + 1, 0).day;
    final candidate = DateTime(_month.year, _month.month, lastDay);
    return candidate.isAfter(now) ? now : candidate;
  }

  Future<void> _delete(ExpenseItem expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지출 삭제'),
        content: Text('「${expense.title}」 내역을 삭제할까요?'),
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
    if (confirmed != true) return;
    try {
      await ExpenseApi.delete(expense.id);
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '지출 관리',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ),
              FilledButton(
                onPressed: _openForm,
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  shape: const StadiumBorder(),
                ),
                child: const Text('+ 지출 등록'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _MonthNavigation(
            month: _month,
            onPrevious: () => _moveMonth(-1),
            onNext: () => _moveMonth(1),
          ),
          const SizedBox(height: 18),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }
    final data = _data;
    if (data == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator(color: _navy)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(data: data),
        const SizedBox(height: 28),
        Text(
          '지출 내역 ${data.expenses.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (data.expenses.isEmpty)
          const _EmptyExpenses()
        else
          for (final expense in data.expenses) ...[
            _ExpenseCard(
              expense: expense,
              onTap: () => _openForm(expense),
              onDelete: () => _delete(expense),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _MonthNavigation extends StatelessWidget {
  const _MonthNavigation({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
        SizedBox(
          width: 130,
          child: Text(
            '${month.year}년 ${month.month}월',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final ExpenseMonth data;

  @override
  Widget build(BuildContext context) {
    final totals = <ExpenseCategory, int>{};
    for (final expense in data.expenses) {
      totals.update(
        expense.category,
        (amount) => amount + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이번 달 지출', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            '${_formatAmount(data.totalAmount)}원',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (totals.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in totals.entries)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${entry.key.label} ${_formatAmount(entry.value)}원',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  final ExpenseItem expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _lightNavy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  expense.category.label.characters.first,
                  style: const TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(expense.date)} · ${expense.category.label}',
                      style: const TextStyle(fontSize: 13, color: _gray),
                    ),
                  ],
                ),
              ),
              Text(
                '${_formatAmount(expense.amount)}원',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 18, color: _gray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 52),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        '이번 달 지출 내역이 없어요',
        textAlign: TextAlign.center,
        style: TextStyle(color: _gray),
      ),
    );
  }
}

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, this.expense, required this.initialDate});

  final ExpenseItem? expense;
  final DateTime initialDate;

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  late DateTime _date;
  late ExpenseCategory _category;
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _memoController;
  bool _saving = false;

  bool get _editing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _date = expense?.date ?? widget.initialDate;
    _category = expense?.category ?? ExpenseCategory.other;
    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense == null ? '' : '${expense.amount}',
    );
    _memoController = TextEditingController(text: expense?.memo ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 10);
    var initialDate = _date.isAfter(now) ? now : _date;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final amount = int.tryParse(_amountController.text);
    if (title.isEmpty) {
      _message('지출명을 입력해 주세요.');
      return;
    }
    if (amount == null || amount <= 0) {
      _message('0원보다 큰 금액을 입력해 주세요.');
      return;
    }
    if (amount > 2147483647) {
      _message('금액이 너무 큽니다.');
      return;
    }
    setState(() => _saving = true);
    try {
      final expense = widget.expense;
      if (expense == null) {
        await ExpenseApi.create(
          date: _date,
          category: _category,
          title: title,
          amount: amount,
          memo: _memoController.text.trim(),
        );
      } else {
        await ExpenseApi.update(
          expense.id,
          date: _date,
          category: _category,
          title: title,
          amount: amount,
          memo: _memoController.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? '지출 수정' : '지출 등록'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FormLabel('카테고리'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in ExpenseCategory.values)
                    ChoiceChip(
                      label: Text(category.label),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                      selectedColor: _lightNavy,
                      labelStyle: TextStyle(
                        color: _category == category ? _navy : _gray,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const _FormLabel('지출명'),
              AppTextField(
                hint: '예: 셔틀콕 1통',
                controller: _titleController,
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              const _FormLabel('금액'),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '예: 18000',
                  suffixText: '원',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _FormLabel('지출일'),
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
                      Text(_formatDate(_date)),
                      const Spacer(),
                      const Icon(Icons.calendar_today_outlined, color: _gray),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _FormLabel('메모'),
              TextField(
                controller: _memoController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: '필요한 내용을 남겨보세요',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_editing ? '수정 완료' : '저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}
