import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/equipment.dart';
import '../models/expense.dart';
import '../models/workout_record.dart';
import 'repositories.dart';

String _iso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
DateTime? _date(Object? value) =>
    value == null ? null : DateTime.parse(value as String);

class LocalDatabase
    implements
        ProfileRepository,
        RecordRepository,
        ExpenseRepository,
        EquipmentRepository {
  LocalDatabase._(this._db);

  final Database _db;

  static Future<LocalDatabase> open() async {
    final path = p.join(await getDatabasesPath(), 'mintonary.db');
    final db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onOpen: _syncModelCatalog,
      onCreate: _create,
    );
    return LocalDatabase._(db);
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE profile (
      id INTEGER PRIMARY KEY CHECK (id = 1), nickname TEXT NOT NULL,
      email TEXT, birth_date TEXT, gender TEXT, local_class TEXT, national_class TEXT)''',
    );
    await db.execute(
      '''CREATE TABLE racket_model (
      id INTEGER PRIMARY KEY, brand TEXT NOT NULL, series TEXT, name TEXT NOT NULL,
      weight TEXT, balance TEXT, flex TEXT, is_custom INTEGER NOT NULL DEFAULT 0)''',
    );
    await db.execute('''CREATE TABLE shoe_model (
      id INTEGER PRIMARY KEY, brand TEXT NOT NULL, name TEXT NOT NULL, width TEXT,
      is_custom INTEGER NOT NULL DEFAULT 0)''');
    await db.execute(
      '''CREATE TABLE equipment (
      id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, model_id INTEGER NOT NULL,
      purchase_date TEXT, price INTEGER, memo TEXT, retired_at TEXT, string_alarm_date TEXT)''',
    );
    await db.execute(
      '''CREATE TABLE string_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT, equipment_id INTEGER NOT NULL,
      name TEXT NOT NULL, tension INTEGER, changed_at TEXT NOT NULL,
      FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE)''',
    );
    await db.execute(
      '''CREATE TABLE grip_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT, equipment_id INTEGER NOT NULL,
      name TEXT NOT NULL, type TEXT, changed_at TEXT NOT NULL,
      FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE)''',
    );
    await db.execute('''CREATE TABLE workout_record (
      id INTEGER PRIMARY KEY AUTOINCREMENT, record_date TEXT NOT NULL, type TEXT NOT NULL,
      title TEXT NOT NULL, place TEXT, coach TEXT, result TEXT, memo TEXT)''');
    await db.execute(
      '''CREATE TABLE expense (
      id INTEGER PRIMARY KEY AUTOINCREMENT, expense_date TEXT NOT NULL,
      category TEXT NOT NULL, title TEXT NOT NULL, amount INTEGER NOT NULL, memo TEXT)''',
    );
    await _createCatalogMetadataTable(db);
    await db.execute(
      'CREATE INDEX idx_workout_date ON workout_record(record_date)',
    );
    await db.execute('CREATE INDEX idx_expense_date ON expense(expense_date)');
    await _syncModelCatalog(db);
    await _createModelIndexes(db);
  }

  static Future<void> _createCatalogMetadataTable(Database db) =>
      db.execute('''CREATE TABLE IF NOT EXISTS app_metadata (
      key TEXT PRIMARY KEY, value TEXT NOT NULL)''');

  static Future<void> _createModelIndexes(Database db) async {
    await db.execute('''CREATE UNIQUE INDEX IF NOT EXISTS
      idx_racket_model_brand_name
      ON racket_model(brand COLLATE NOCASE, name COLLATE NOCASE)''');
    await db.execute('''CREATE UNIQUE INDEX IF NOT EXISTS
      idx_shoe_model_brand_name
      ON shoe_model(brand COLLATE NOCASE, name COLLATE NOCASE)''');
  }

  static Future<void> _syncModelCatalog(Database db) async {
    final json = await rootBundle.loadString(
      'assets/data/equipment_models.json',
    );
    final catalog = jsonDecode(json) as Map<String, dynamic>;
    final catalogVersion = catalog['catalogVersion'] as int;
    final stored = await db.query(
      'app_metadata',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['model_catalog_version'],
      limit: 1,
    );
    final storedVersion = stored.isEmpty
        ? 0
        : int.tryParse(stored.first['value'] as String) ?? 0;
    if (storedVersion >= catalogVersion) return;

    for (final value in catalog['rackets'] as List<dynamic>) {
      final model = Map<String, dynamic>.from(value as Map);
      await _upsertCatalogModel(db, 'racket_model', {
        'brand': model['brand'],
        'series': model['series'],
        'name': model['name'],
        'weight': model['weight'],
        'balance': model['balance'],
        'flex': model['flex'],
        'is_custom': 0,
      });
    }
    for (final value in catalog['shoes'] as List<dynamic>) {
      final model = Map<String, dynamic>.from(value as Map);
      await _upsertCatalogModel(db, 'shoe_model', {
        'brand': model['brand'],
        'name': model['name'],
        'width': model['width'],
        'is_custom': 0,
      });
    }
    await db.insert('app_metadata', {
      'key': 'model_catalog_version',
      'value': catalogVersion.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> _upsertCatalogModel(
    Database db,
    String table,
    Map<String, Object?> model,
  ) async {
    final existing = await db.query(
      table,
      columns: ['id'],
      where: 'brand = ? COLLATE NOCASE AND name = ? COLLATE NOCASE',
      whereArgs: [model['brand'], model['name']],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert(table, model);
      return;
    }
    await db.update(
      table,
      model,
      where: 'id = ?',
      whereArgs: [existing.first['id']],
    );
  }

  @override
  Future<LocalProfile?> load() async {
    final rows = await _db.query('profile', where: 'id = 1');
    if (rows.isEmpty) return null;
    final row = rows.first;
    return LocalProfile(
      nickname: row['nickname'] as String,
      email: row['email'] as String?,
      birthDate: _date(row['birth_date']),
      gender: row['gender'] as String?,
      localClass: row['local_class'] as String?,
      nationalClass: row['national_class'] as String?,
    );
  }

  @override
  Future<void> save(LocalProfile profile) => _db.insert('profile', {
    'id': 1,
    'nickname': profile.nickname,
    'email': profile.email,
    'birth_date': profile.birthDate == null ? null : _iso(profile.birthDate!),
    'gender': profile.gender,
    'local_class': profile.localClass,
    'national_class': profile.nationalClass,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  @override
  Future<List<WorkoutRecord>> fetchRecordMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    final rows = await _db.query(
      'workout_record',
      where: 'record_date BETWEEN ? AND ?',
      whereArgs: [_iso(start), _iso(end)],
      orderBy: 'record_date ASC, id ASC',
    );
    return rows
        .map(
          (r) => WorkoutRecord(
            id: r['id'] as int,
            date: DateTime.parse(r['record_date'] as String),
            type: r['type'] as String,
            title: r['title'] as String,
            place: r['place'] as String?,
            coach: r['coach'] as String?,
            result: r['result'] as String?,
            memo: r['memo'] as String?,
          ),
        )
        .toList();
  }

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
    await _db.insert('workout_record', {
      'record_date': _iso(date),
      'type': type,
      'title': title,
      'place': place,
      'coach': coach,
      'result': result,
      'memo': memo,
    });
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
  }) async {
    String? optional(String? value) {
      final trimmed = value?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    final updated = await _db.update(
      'workout_record',
      {
        'record_date': _iso(date),
        'type': type,
        'title': title.trim(),
        'place': optional(place),
        'coach': optional(coach),
        'result': optional(result),
        'memo': optional(memo),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updated == 0) throw Exception('운동 기록을 찾을 수 없습니다.');
  }

  @override
  Future<void> deleteRecord(int id) async =>
      _db.delete('workout_record', where: 'id = ?', whereArgs: [id]);

  @override
  Future<ExpenseMonth> fetchExpenseMonth(int year, int month) async {
    final rows = await _db.query(
      'expense',
      where: 'expense_date BETWEEN ? AND ?',
      whereArgs: [
        _iso(DateTime(year, month, 1)),
        _iso(DateTime(year, month + 1, 0)),
      ],
      orderBy: 'expense_date DESC, id DESC',
    );
    final items = rows.map(_expenseFromRow).toList();
    return ExpenseMonth(
      totalAmount: items.fold(0, (sum, item) => sum + item.amount),
      recentExpense: items.isEmpty ? null : items.first,
      expenses: items,
    );
  }

  ExpenseItem _expenseFromRow(Map<String, Object?> r) => ExpenseItem(
    id: r['id'] as int,
    date: DateTime.parse(r['expense_date'] as String),
    category: ExpenseCategory.fromStorage(r['category'] as String),
    title: r['title'] as String,
    amount: r['amount'] as int,
    memo: r['memo'] as String?,
  );

  @override
  Future<void> createExpense({
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  }) async {
    await _db.insert('expense', {
      'expense_date': _iso(date),
      'category': category.storageValue,
      'title': title,
      'amount': amount,
      'memo': memo,
    });
  }

  @override
  Future<void> updateExpense(
    int id, {
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  }) async {
    await _db.update(
      'expense',
      {
        'expense_date': _iso(date),
        'category': category.storageValue,
        'title': title,
        'amount': amount,
        'memo': memo,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteExpense(int id) async =>
      _db.delete('expense', where: 'id = ?', whereArgs: [id]);

  @override
  Future<List<RacketModelOption>> fetchRacketModels() async =>
      (await _db.query('racket_model', orderBy: 'brand, name'))
          .map(
            (r) => RacketModelOption(
              id: r['id'] as int,
              brand: r['brand'] as String,
              name: r['name'] as String,
            ),
          )
          .toList();
  @override
  Future<List<ShoeModelOption>> fetchShoeModels() async =>
      (await _db.query('shoe_model', orderBy: 'brand, name'))
          .map(
            (r) => ShoeModelOption(
              id: r['id'] as int,
              brand: r['brand'] as String,
              name: r['name'] as String,
            ),
          )
          .toList();

  @override
  Future<int> addCustomModel({
    required String type,
    required String brand,
    required String name,
  }) async {
    final table = type == 'RACKET' ? 'racket_model' : 'shoe_model';
    final cleanBrand = brand.trim();
    final cleanName = name.trim();
    if (cleanBrand.isEmpty || cleanName.isEmpty) {
      throw Exception('브랜드와 모델명을 입력해 주세요.');
    }
    final existing = await _db.query(
      table,
      columns: ['id'],
      where: 'brand = ? COLLATE NOCASE AND name = ? COLLATE NOCASE',
      whereArgs: [cleanBrand, cleanName],
      limit: 1,
    );
    if (existing.isNotEmpty) return existing.first['id'] as int;
    return _db.insert(table, {
      'brand': cleanBrand,
      'name': cleanName,
      'is_custom': 1,
    });
  }

  @override
  Future<EquipmentList> fetchEquipments() async {
    final rackets = await _db.rawQuery(
      '''SELECT e.*, m.brand, m.name,
      (SELECT name FROM string_history WHERE equipment_id=e.id ORDER BY changed_at DESC,id DESC LIMIT 1) string_name,
      (SELECT tension FROM string_history WHERE equipment_id=e.id ORDER BY changed_at DESC,id DESC LIMIT 1) tension,
      (SELECT changed_at FROM string_history WHERE equipment_id=e.id ORDER BY changed_at DESC,id DESC LIMIT 1) strung_at,
      (SELECT name FROM grip_history WHERE equipment_id=e.id ORDER BY changed_at DESC,id DESC LIMIT 1) grip_name,
      (SELECT changed_at FROM grip_history WHERE equipment_id=e.id ORDER BY changed_at DESC,id DESC LIMIT 1) wrapped_at
      FROM equipment e JOIN racket_model m ON m.id=e.model_id WHERE e.type='RACKET' ORDER BY e.id DESC''',
    );
    final shoes = await _db.rawQuery(
      '''SELECT e.*, m.brand, m.name FROM equipment e
      JOIN shoe_model m ON m.id=e.model_id WHERE e.type='SHOE' ORDER BY e.id DESC''',
    );
    return EquipmentList(
      rackets: rackets
          .map(
            (r) => RacketSummary(
              id: r['id'] as int,
              brand: r['brand'] as String,
              name: r['name'] as String,
              purchaseDate: _date(r['purchase_date']),
              price: r['price'] as int?,
              inUse: r['retired_at'] == null,
              stringName: r['string_name'] as String?,
              tension: r['tension'] as int?,
              strungAt: _date(r['strung_at']),
              gripName: r['grip_name'] as String?,
              wrappedAt: _date(r['wrapped_at']),
            ),
          )
          .toList(),
      shoes: shoes
          .map(
            (r) => ShoeSummary(
              id: r['id'] as int,
              brand: r['brand'] as String,
              name: r['name'] as String,
              purchaseDate: _date(r['purchase_date']),
              price: r['price'] as int?,
              inUse: r['retired_at'] == null,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<EquipmentDetail> fetchDetail(int id) async {
    final equipmentRows = await _db.query(
      'equipment',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (equipmentRows.isEmpty) throw Exception('장비를 찾을 수 없습니다.');
    final e = equipmentRows.first;
    final type = e['type'] as String;
    RacketInfo? racket;
    ShoeInfo? shoe;
    if (type == 'RACKET') {
      final m = (await _db.query(
        'racket_model',
        where: 'id = ?',
        whereArgs: [e['model_id']],
      )).first;
      final strings = await _db.query(
        'string_history',
        where: 'equipment_id = ?',
        whereArgs: [id],
        orderBy: 'changed_at DESC, id DESC',
      );
      final grips = await _db.query(
        'grip_history',
        where: 'equipment_id = ?',
        whereArgs: [id],
        orderBy: 'changed_at DESC, id DESC',
      );
      racket = RacketInfo(
        brand: m['brand'] as String,
        series: m['series'] as String?,
        name: m['name'] as String,
        weight: m['weight'] as String?,
        balance: m['balance'] as String?,
        flex: m['flex'] as String?,
        stringAlarmDate: _date(e['string_alarm_date']),
        stringHistories: strings
            .map(
              (r) => StringHistoryItem(
                id: r['id'] as int,
                name: r['name'] as String,
                tension: r['tension'] as int?,
                strungAt: DateTime.parse(r['changed_at'] as String),
              ),
            )
            .toList(),
        gripHistories: grips
            .map(
              (r) => GripHistoryItem(
                id: r['id'] as int,
                name: r['name'] as String,
                type: r['type'] as String?,
                wrappedAt: DateTime.parse(r['changed_at'] as String),
              ),
            )
            .toList(),
      );
    } else {
      final m = (await _db.query(
        'shoe_model',
        where: 'id = ?',
        whereArgs: [e['model_id']],
      )).first;
      shoe = ShoeInfo(
        brand: m['brand'] as String,
        name: m['name'] as String,
        width: m['width'] as String?,
      );
    }
    return EquipmentDetail(
      id: id,
      type: type,
      purchaseDate: _date(e['purchase_date']),
      price: e['price'] as int?,
      memo: e['memo'] as String?,
      inUse: e['retired_at'] == null,
      racket: racket,
      shoe: shoe,
    );
  }

  @override
  Future<void> register({
    required String type,
    required int modelId,
    DateTime? purchaseDate,
    int? price,
    bool addToExpenses = false,
    String? stringName,
    int? tension,
    DateTime? strungAt,
    String? gripName,
    String? gripType,
    DateTime? wrappedAt,
  }) async {
    await _db.transaction((txn) async {
      final id = await txn.insert('equipment', {
        'type': type,
        'model_id': modelId,
        'purchase_date': purchaseDate == null ? null : _iso(purchaseDate),
        'price': price,
      });
      if (stringName?.isNotEmpty == true) {
        await txn.insert('string_history', {
          'equipment_id': id,
          'name': stringName,
          'tension': tension,
          'changed_at': _iso(strungAt ?? purchaseDate ?? DateTime.now()),
        });
      }
      if (gripName?.isNotEmpty == true) {
        await txn.insert('grip_history', {
          'equipment_id': id,
          'name': gripName,
          'type': gripType,
          'changed_at': _iso(wrappedAt ?? purchaseDate ?? DateTime.now()),
        });
      }
      if (addToExpenses && price != null) {
        final table = type == 'RACKET' ? 'racket_model' : 'shoe_model';
        final model = (await txn.query(
          table,
          where: 'id = ?',
          whereArgs: [modelId],
        )).first;
        await txn.insert('expense', {
          'expense_date': _iso(purchaseDate ?? DateTime.now()),
          'category': ExpenseCategory.equipment.storageValue,
          'title': '${model['brand']} ${model['name']}',
          'amount': price,
        });
      }
    });
  }

  @override
  Future<void> updateEquipment(
    int equipmentId, {
    required int modelId,
    DateTime? purchaseDate,
    int? price,
    String? memo,
  }) async {
    final rows = await _db.query(
      'equipment',
      columns: ['type'],
      where: 'id = ?',
      whereArgs: [equipmentId],
    );
    if (rows.isEmpty) throw Exception('장비를 찾을 수 없습니다.');
    final modelTable = rows.first['type'] == 'RACKET'
        ? 'racket_model'
        : 'shoe_model';
    final modelCount = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM $modelTable WHERE id = ?', [
        modelId,
      ]),
    );
    if (modelCount != 1) throw Exception('선택한 장비 모델을 찾을 수 없습니다.');
    await _db.update(
      'equipment',
      {
        'model_id': modelId,
        'purchase_date': purchaseDate == null ? null : _iso(purchaseDate),
        'price': price,
        'memo': memo?.trim().isEmpty == true ? null : memo?.trim(),
      },
      where: 'id = ?',
      whereArgs: [equipmentId],
    );
  }

  @override
  Future<void> deleteEquipment(int equipmentId) async {
    await _db.transaction((txn) async {
      await txn.delete(
        'string_history',
        where: 'equipment_id = ?',
        whereArgs: [equipmentId],
      );
      await txn.delete(
        'grip_history',
        where: 'equipment_id = ?',
        whereArgs: [equipmentId],
      );
      final deleted = await txn.delete(
        'equipment',
        where: 'id = ?',
        whereArgs: [equipmentId],
      );
      if (deleted == 0) throw Exception('장비를 찾을 수 없습니다.');
    });
  }

  @override
  Future<void> addStringChange(
    int equipmentId, {
    required String name,
    int? tension,
    required DateTime strungAt,
  }) async => _db.insert('string_history', {
    'equipment_id': equipmentId,
    'name': name,
    'tension': tension,
    'changed_at': _iso(strungAt),
  });
  @override
  Future<void> deleteStringChange(int equipmentId, int historyId) async =>
      _db.delete(
        'string_history',
        where: 'id = ? AND equipment_id = ?',
        whereArgs: [historyId, equipmentId],
      );
  @override
  Future<void> addGripChange(
    int equipmentId, {
    required String name,
    required String type,
    required DateTime wrappedAt,
  }) async => _db.insert('grip_history', {
    'equipment_id': equipmentId,
    'name': name,
    'type': type,
    'changed_at': _iso(wrappedAt),
  });
  @override
  Future<void> deleteGripChange(int equipmentId, int historyId) async =>
      _db.delete(
        'grip_history',
        where: 'id = ? AND equipment_id = ?',
        whereArgs: [historyId, equipmentId],
      );
  @override
  Future<void> setStringAlarm(int equipmentId, DateTime? date) async =>
      _db.update(
        'equipment',
        {'string_alarm_date': date == null ? null : _iso(date)},
        where: 'id = ?',
        whereArgs: [equipmentId],
      );
  @override
  Future<void> setStatus(int equipmentId, bool inUse) async => _db.update(
    'equipment',
    {'retired_at': inUse ? null : _iso(DateTime.now())},
    where: 'id = ?',
    whereArgs: [equipmentId],
  );
}
