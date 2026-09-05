import 'package:flutter_test/flutter_test.dart';
import 'package:mintonary/models/expense.dart';

void main() {
  test('모든 지출 카테고리는 저장값으로 왕복 변환된다', () {
    for (final category in ExpenseCategory.values) {
      expect(ExpenseCategory.fromStorage(category.storageValue), category);
    }
  });

  test('알 수 없는 저장값은 기타 카테고리로 안전하게 처리한다', () {
    expect(ExpenseCategory.fromStorage('LEGACY_VALUE'), ExpenseCategory.other);
  });
}
