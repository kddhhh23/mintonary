enum ExpenseCategory {
  court('COURT', '체육관비'),
  lesson('LESSON', '레슨비'),
  shuttlecock('SHUTTLECOCK', '셔틀콕'),
  equipment('EQUIPMENT', '장비'),
  tournament('TOURNAMENT', '대회'),
  other('OTHER', '기타');

  const ExpenseCategory(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static ExpenseCategory fromStorage(String value) => values.firstWhere(
    (category) => category.storageValue == value,
    orElse: () => other,
  );
}

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.date,
    required this.category,
    required this.title,
    required this.amount,
    this.memo,
  });

  final int id;
  final DateTime date;
  final ExpenseCategory category;
  final String title;
  final int amount;
  final String? memo;
}

class ExpenseMonth {
  const ExpenseMonth({
    required this.totalAmount,
    required this.recentExpense,
    required this.expenses,
  });

  final int totalAmount;
  final ExpenseItem? recentExpense;
  final List<ExpenseItem> expenses;
}
