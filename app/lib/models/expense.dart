enum ExpenseCategory {
  court('COURT', '체육관비'),
  lesson('LESSON', '레슨비'),
  shuttlecock('SHUTTLECOCK', '셔틀콕'),
  equipment('EQUIPMENT', '장비'),
  tournament('TOURNAMENT', '대회'),
  other('OTHER', '기타');

  const ExpenseCategory(this.serverValue, this.label);

  final String serverValue;
  final String label;

  static ExpenseCategory fromServer(String value) => values.firstWhere(
    (category) => category.serverValue == value,
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

  ExpenseItem.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      date = DateTime.parse(json['date'] as String),
      category = ExpenseCategory.fromServer(json['category'] as String),
      title = json['title'] as String,
      amount = json['amount'] as int,
      memo = json['memo'] as String?;

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

  ExpenseMonth.fromJson(Map<String, dynamic> json)
    : totalAmount = json['totalAmount'] as int,
      recentExpense = json['recentExpense'] == null
          ? null
          : ExpenseItem.fromJson(json['recentExpense'] as Map<String, dynamic>),
      expenses = (json['expenses'] as List)
          .map((item) => ExpenseItem.fromJson(item as Map<String, dynamic>))
          .toList();

  final int totalAmount;
  final ExpenseItem? recentExpense;
  final List<ExpenseItem> expenses;
}
