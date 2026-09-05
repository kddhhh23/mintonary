import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mintonary/data/app_repositories.dart';
import 'package:mintonary/data/repositories.dart';
import 'package:mintonary/main.dart';
import 'package:mintonary/models/expense.dart';
import 'package:mintonary/models/workout_record.dart';
import 'package:mintonary/screens/expense_screen.dart';
import 'package:mintonary/screens/profile_setup_screen.dart';
import 'package:mintonary/screens/record_screen.dart';

void main() {
  void usePhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('프로필 화면은 닉네임 없이 저장하지 않는다', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(const MintonaryApp(home: ProfileSetupScreen()));

    await tester.tap(find.text('시작하기'));
    await tester.pump();

    expect(find.text('닉네임을 입력해 주세요.'), findsOneWidget);
  });

  testWidgets('지출 폼은 지출명 없이 저장하지 않는다', (tester) async {
    usePhoneSize(tester);
    AppRepositories.expenses = _FakeExpenseRepository();
    await tester.pumpWidget(
      MintonaryApp(home: ExpenseFormScreen(initialDate: DateTime(2026, 9, 5))),
    );

    await tester.tap(find.text('저장'));
    await tester.pump();

    expect(find.text('지출명을 입력해 주세요.'), findsOneWidget);
  });

  testWidgets('지출 폼은 금액을 검증하고 쉼표 금액을 저장한다', (tester) async {
    usePhoneSize(tester);
    final expensesRepository = _FakeExpenseRepository();
    AppRepositories.expenses = expensesRepository;
    await tester.pumpWidget(
      MintonaryApp(home: ExpenseFormScreen(initialDate: DateTime(2026, 9, 5))),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '셔틀콕 구매');
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('저장'));
    await tester.pump();
    await tester.tap(find.text('저장'));
    await tester.pump();
    expect(find.text('0원보다 큰 금액을 입력해 주세요.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));

    await tester.enterText(fields.at(1), '28000');
    tester.testTextInput.hide();
    await tester.tap(find.text(ExpenseCategory.shuttlecock.label));
    await tester.ensureVisible(find.text('저장'));
    await tester.pump();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(expensesRepository.expenses, hasLength(1));
    expect(expensesRepository.expenses.single.title, '셔틀콕 구매');
    expect(expensesRepository.expenses.single.amount, 28000);
    expect(
      expensesRepository.expenses.single.category,
      ExpenseCategory.shuttlecock,
    );
  });

  testWidgets('운동 기록 폼은 제목을 검증한 뒤 기록을 저장한다', (tester) async {
    usePhoneSize(tester);
    final recordsRepository = _FakeRecordRepository();
    AppRepositories.records = recordsRepository;
    await tester.pumpWidget(
      const MintonaryApp(home: Scaffold(body: RecordScreen())),
    );
    await tester.pump();

    await tester.tap(find.text('+ 기록 남기기'));
    await tester.pumpAndSettle();
    expect(find.text('기록 남기기'), findsOneWidget);

    await tester.tap(find.text('저장'));
    await tester.pump();
    expect(find.text('한 줄 기록을 입력해 주세요.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '저녁 클럽 운동');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(recordsRepository.records, hasLength(1));
    expect(recordsRepository.records.single.title, '저녁 클럽 운동');
    expect(recordsRepository.records.single.type, 'GENERAL');
  });
}

class _FakeExpenseRepository implements ExpenseRepository {
  final List<ExpenseItem> expenses = [];

  @override
  Future<ExpenseMonth> fetchExpenseMonth(int year, int month) async {
    final items = expenses
        .where(
          (expense) => expense.date.year == year && expense.date.month == month,
        )
        .toList();
    return ExpenseMonth(
      totalAmount: items.fold(0, (sum, expense) => sum + expense.amount),
      recentExpense: items.isEmpty ? null : items.first,
      expenses: items,
    );
  }

  @override
  Future<void> createExpense({
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  }) async {
    expenses.add(
      ExpenseItem(
        id: expenses.length + 1,
        date: date,
        category: category,
        title: title,
        amount: amount,
        memo: memo,
      ),
    );
  }

  @override
  Future<void> updateExpense(
    int id, {
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  }) async {}

  @override
  Future<void> deleteExpense(int id) async {
    expenses.removeWhere((expense) => expense.id == id);
  }
}

class _FakeRecordRepository implements RecordRepository {
  final List<WorkoutRecord> records = [];

  @override
  Future<List<WorkoutRecord>> fetchRecordMonth(int year, int month) async =>
      records
          .where(
            (record) => record.date.year == year && record.date.month == month,
          )
          .toList();

  @override
  Future<void> createRecord({
    required DateTime date,
    required String type,
    required String title,
    String? place,
    String? coach,
    String? result,
    String? memo,
  }) async {
    records.add(
      WorkoutRecord(
        id: records.length + 1,
        date: date,
        type: type,
        title: title,
        place: place,
        coach: coach,
        result: result,
        memo: memo,
      ),
    );
  }

  @override
  Future<void> updateRecord(
    int id, {
    required DateTime date,
    required String type,
    required String title,
    String? place,
    String? coach,
    String? result,
    String? memo,
  }) async {}

  @override
  Future<void> deleteRecord(int id) async {
    records.removeWhere((record) => record.id == id);
  }
}
