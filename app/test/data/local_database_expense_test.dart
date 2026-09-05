import 'package:flutter_test/flutter_test.dart';
import 'package:mintonary/data/local_database.dart';
import 'package:mintonary/models/expense.dart';

import '../helpers/test_database.dart';

void main() {
  late LocalDatabase database;

  setUp(() async => database = await openTestDatabase());
  tearDown(() => database.close());

  test('지출을 월별로 집계하고 최신순으로 조회한다', () async {
    await database.createExpense(
      date: DateTime(2026, 9, 3),
      category: ExpenseCategory.court,
      title: '체육관 대관',
      amount: 12000,
    );
    await database.createExpense(
      date: DateTime(2026, 9, 21),
      category: ExpenseCategory.shuttlecock,
      title: '셔틀콕',
      amount: 28000,
      memo: '클럽 공용',
    );
    await database.createExpense(
      date: DateTime(2026, 10, 1),
      category: ExpenseCategory.lesson,
      title: '다음 달 레슨',
      amount: 50000,
    );

    final month = await database.fetchExpenseMonth(2026, 9);
    expect(month.totalAmount, 40000);
    expect(month.expenses, hasLength(2));
    expect(month.recentExpense?.title, '셔틀콕');
    expect(month.expenses.first.category, ExpenseCategory.shuttlecock);
    expect(month.expenses.first.memo, '클럽 공용');
    expect((await database.fetchExpenseMonth(2026, 8)).totalAmount, 0);
  });

  test('지출 수정과 삭제가 집계에 반영된다', () async {
    await database.createExpense(
      date: DateTime(2026, 9, 5),
      category: ExpenseCategory.other,
      title: '기타',
      amount: 1000,
    );
    final id = (await database.fetchExpenseMonth(2026, 9)).expenses.single.id;

    await database.updateExpense(
      id,
      date: DateTime(2026, 9, 6),
      category: ExpenseCategory.tournament,
      title: '대회 참가비',
      amount: 30000,
      memo: '지역 대회',
    );

    final updatedMonth = await database.fetchExpenseMonth(2026, 9);
    expect(updatedMonth.totalAmount, 30000);
    expect(updatedMonth.expenses.single.category, ExpenseCategory.tournament);
    expect(updatedMonth.expenses.single.title, '대회 참가비');
    expect(updatedMonth.expenses.single.memo, '지역 대회');

    await database.deleteExpense(id);
    expect((await database.fetchExpenseMonth(2026, 9)).expenses, isEmpty);
  });

  test('존재하지 않는 지출 수정은 실패한다', () async {
    expect(
      database.updateExpense(
        99999,
        date: DateTime(2026, 9, 1),
        category: ExpenseCategory.other,
        title: '없는 지출',
        amount: 1,
      ),
      throwsException,
    );
  });
}
