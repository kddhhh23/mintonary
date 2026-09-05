import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mintonary/data/local_database.dart';
import 'package:mintonary/data/repositories.dart';
import 'package:mintonary/models/expense.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('앱을 재실행해도 사용자 데이터가 유지되고 카탈로그가 중복되지 않는다', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'mintonary_database_test_',
    );
    final databasePath = p.join(tempDirectory.path, 'mintonary.db');

    try {
      var database = await LocalDatabase.open(databasePath: databasePath);
      final racket = (await database.fetchRacketModels()).first;
      await database.save(
        LocalProfile(nickname: '재실행 사용자', birthDate: DateTime(2000, 1, 2)),
      );
      await database.createRecord(
        date: DateTime(2026, 9, 5),
        type: 'GENERAL',
        title: '재실행 전 운동',
      );
      await database.createExpense(
        date: DateTime(2026, 9, 5),
        category: ExpenseCategory.court,
        title: '재실행 전 지출',
        amount: 10000,
      );
      await database.register(
        type: 'RACKET',
        modelId: racket.id,
        purchaseDate: DateTime(2026, 9, 5),
      );
      await database.close();

      database = await LocalDatabase.open(databasePath: databasePath);
      expect((await database.load())?.nickname, '재실행 사용자');
      expect(await database.fetchRecordMonth(2026, 9), hasLength(1));
      expect(
        (await database.fetchExpenseMonth(2026, 9)).expenses,
        hasLength(1),
      );
      expect((await database.fetchEquipments()).rackets, hasLength(1));
      expect(await database.fetchRacketModels(), hasLength(243));
      expect(await database.fetchShoeModels(), hasLength(86));
      await database.close();
    } finally {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    }
  });
}
