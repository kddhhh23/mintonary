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
      version: 5,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _create,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await _seedModels(db);
          await _normalizeModelBrands(db);
        }
      },
    );
    return LocalDatabase._(db);
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE profile (
      id INTEGER PRIMARY KEY CHECK (id = 1), nickname TEXT NOT NULL,
      email TEXT, birth_date TEXT, gender TEXT, local_class TEXT, national_class TEXT)''',
    );
    await db.execute('''CREATE TABLE racket_model (
      id INTEGER PRIMARY KEY, brand TEXT NOT NULL, series TEXT, name TEXT NOT NULL,
      weight TEXT, balance TEXT, flex TEXT)''');
    await db.execute(
      '''CREATE TABLE shoe_model (
      id INTEGER PRIMARY KEY, brand TEXT NOT NULL, name TEXT NOT NULL, width TEXT)''',
    );
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
    await db.execute(
      'CREATE INDEX idx_workout_date ON workout_record(record_date)',
    );
    await db.execute('CREATE INDEX idx_expense_date ON expense(expense_date)');
    await _seedModels(db);
    await _normalizeModelBrands(db);
  }

  static Future<void> _normalizeModelBrands(Database db) async {
    const brands = {
      'YONEX': '요넥스',
      'VICTOR': '빅터',
      'LI-NING': '리닝',
      'LI NING': '리닝',
      'LINING': '리닝',
      'APACS': '아펙스',
      'MIZUNO': '미즈노',
      'TECHNIST': '테크니스트',
    };
    for (final entry in brands.entries) {
      await db.update(
        'racket_model',
        {'brand': entry.value},
        where: 'UPPER(brand) = ?',
        whereArgs: [entry.key],
      );
      await db.update(
        'shoe_model',
        {'brand': entry.value},
        where: 'UPPER(brand) = ?',
        whereArgs: [entry.key],
      );
    }
  }

  static Future<void> _seedModels(Database db) async {
    const rackets = [
      [1, '요넥스', '아스트록스', '아스트록스 99', 'U4', '헤드 헤비', '스티프'],
      [2, '요넥스', '아스트록스', '아스트록스 88D', 'U4', '헤드 헤비', '스티프'],
      [3, '요넥스', '나노플레어', '나노플레어 800', 'U4', '헤드 라이트', '스티프'],
      [4, '빅터', '썬더', '썬더 TK-F', 'U3', '헤드 헤비', '스티프'],
      [5, '빅터', '오라 스피드', '오라 스피드 100X', 'U4', '이븐', '미디엄'],
      [6, '리닝', '에어로너트', '에어로너트 9000', 'U4', '헤드 헤비', '스티프'],
      [7, '리닝', '액스포스', '액스포스 80', 'U4', '헤드 헤비', '스티프'],
      [8, '요넥스', '아스트록스', '아스트록스 100 ZZ', null, null, null],
      [9, '요넥스', '아스트록스', '아스트록스 100 TOUR', null, null, null],
      [10, '요넥스', '아스트록스', '아스트록스 100 GAME', null, null, null],
      [11, '요넥스', '아스트록스', '아스트록스 99 PRO', null, null, null],
      [12, '요넥스', '아스트록스', '아스트록스 99 TOUR', null, null, null],
      [13, '요넥스', '아스트록스', '아스트록스 99 PLAY', null, null, null],
      [14, '요넥스', '아스트록스', '아스트록스 88D PRO', null, null, null],
      [15, '요넥스', '아스트록스', '아스트록스 88D TOUR', null, null, null],
      [16, '요넥스', '아스트록스', '아스트록스 88D GAME', null, null, null],
      [17, '요넥스', '아스트록스', '아스트록스 88D PLAY', null, null, null],
      [18, '요넥스', '아스트록스', '아스트록스 88S PRO', null, null, null],
      [19, '요넥스', '아스트록스', '아스트록스 88S TOUR', null, null, null],
      [20, '요넥스', '아스트록스', '아스트록스 88S GAME', null, null, null],
      [21, '요넥스', '아스트록스', '아스트록스 88S PLAY', null, null, null],
      [22, '요넥스', '아스트록스', '아스트록스 77 PRO', null, null, null],
      [23, '요넥스', '아스트록스', '아스트록스 77 TOUR', null, null, null],
      [24, '요넥스', '아스트록스', '아스트록스 77 PLAY', null, null, null],
      [25, '요넥스', '아스트록스', '아스트록스 NEXTAGE', null, null, null],
      [26, '요넥스', '아크세이버', '아크세이버 11 PRO', null, null, null],
      [27, '요넥스', '아크세이버', '아크세이버 11 TOUR', null, null, null],
      [28, '요넥스', '아크세이버', '아크세이버 11 PLAY', null, null, null],
      [29, '요넥스', '아크세이버', '아크세이버 7 PRO', null, null, null],
      [30, '요넥스', '아크세이버', '아크세이버 7 TOUR', null, null, null],
      [31, '요넥스', '아크세이버', '아크세이버 7 PLAY', null, null, null],
      [32, '요넥스', '나노플레어', '나노플레어 1000 Z', null, null, null],
      [33, '요넥스', '나노플레어', '나노플레어 1000 TOUR', null, null, null],
      [34, '요넥스', '나노플레어', '나노플레어 1000 GAME', null, null, null],
      [35, '요넥스', '나노플레어', '나노플레어 1000 PLAY', null, null, null],
      [36, '요넥스', '나노플레어', '나노플레어 800 PRO', null, null, null],
      [37, '요넥스', '나노플레어', '나노플레어 800 TOUR', null, null, null],
      [38, '요넥스', '나노플레어', '나노플레어 800 PLAY', null, null, null],
      [39, '요넥스', '나노플레어', '나노플레어 700 PRO', null, null, null],
      [40, '요넥스', '나노플레어', '나노플레어 700 TOUR', null, null, null],
      [41, '요넥스', '나노플레어', '나노플레어 700 GAME', null, null, null],
      [42, '요넥스', '나노플레어', '나노플레어 700 PLAY', null, null, null],
      [43, '요넥스', '나노플레어', '나노플레어 NEXTAGE', null, null, null],
      [44, '빅터', '스러스터', '스러스터 류가 II PRO', null, null, null],
      [45, '빅터', '스러스터', '스러스터 류가 II', null, null, null],
      [46, '빅터', '스러스터', '스러스터 류가 TD', null, null, null],
      [47, '빅터', '스러스터', '스러스터 류가 MUSE', null, null, null],
      [48, '빅터', '스러스터', '스러스터 F Enhanced', null, null, null],
      [49, '빅터', '스러스터', '스러스터 TTY ULTIMA', null, null, null],
      [50, '빅터', '스러스터', '스러스터 K FALCON Enhanced', null, null, null],
      [51, '빅터', '스러스터', '스러스터 K 220H II', null, null, null],
      [52, '빅터', '스러스터', '스러스터 K 30', null, null, null],
      [53, '빅터', '아우라스피드', '아우라스피드 FANTOME', null, null, null],
      [54, '빅터', '아우라스피드', '아우라스피드 100X ULTRA', null, null, null],
      [55, '빅터', '아우라스피드', '아우라스피드 100X', null, null, null],
      [56, '빅터', '아우라스피드', '아우라스피드 90K II', null, null, null],
      [57, '빅터', '아우라스피드', '아우라스피드 HS PLUS', null, null, null],
      [58, '빅터', '아우라스피드', '아우라스피드 90F', null, null, null],
      [59, '빅터', '아우라스피드', '아우라스피드 9000', null, null, null],
      [60, '빅터', '아우라스피드', '아우라스피드 8000', null, null, null],
      [61, '빅터', '아우라스피드', '아우라스피드 7000', null, null, null],
      [62, '빅터', '아우라스피드', '아우라스피드 30H', null, null, null],
      [63, '빅터', '드라이브X', '드라이브X 10 METALLIC', null, null, null],
      [64, '빅터', '드라이브X', '드라이브X 9X', null, null, null],
      [65, '빅터', '드라이브X', '드라이브X 12', null, null, null],
      [66, '빅터', '드라이브X', '드라이브X 8S', null, null, null],
      [67, '빅터', '드라이브X', '드라이브X 7X', null, null, null],
      [68, '리닝', '액스포스', '액스포스 100 II', null, null, null],
      [69, '리닝', '액스포스', '액스포스 100', null, null, null],
      [70, '리닝', '액스포스', '액스포스 90 MAX', null, null, null],
      [71, '리닝', '액스포스', '액스포스 90', null, null, null],
      [72, '리닝', '액스포스', '액스포스 80 LIGHT', null, null, null],
      [73, '리닝', '액스포스', '액스포스 70', null, null, null],
      [74, '리닝', '액스포스', '액스포스 40', null, null, null],
      [75, '리닝', '액스포스', '액스포스 30', null, null, null],
      [76, '리닝', '액스포스', '액스포스 20', null, null, null],
      [77, '리닝', '액스포스', '액스포스 10', null, null, null],
      [78, '리닝', '액스포스', '액스포스 CANNON PRO', null, null, null],
      [79, '리닝', '액스포스', '액스포스 CANNON', null, null, null],
      [80, '리닝', '액스포스', '액스포스 BIG BANG', null, null, null],
      [81, '리닝', '블레이덱스', '블레이덱스 900', null, null, null],
      [82, '리닝', '블레이덱스', '블레이덱스 900 SUN MAX', null, null, null],
      [83, '리닝', '블레이덱스', '블레이덱스 900 MOON MAX', null, null, null],
      [84, '리닝', '블레이덱스', '블레이덱스 800', null, null, null],
      [85, '리닝', '블레이덱스', '블레이덱스 700', null, null, null],
      [86, '리닝', '블레이덱스', '블레이덱스 500', null, null, null],
      [87, '리닝', '블레이덱스', '블레이덱스 200', null, null, null],
      [88, '리닝', '블레이덱스', '블레이덱스 100', null, null, null],
      [89, '리닝', '블레이덱스', '블레이덱스 73 LIGHT', null, null, null],
      [90, '리닝', '블레이덱스', '블레이덱스 ASSASSIN', null, null, null],
      [91, '리닝', '할버텍', '할버텍 9000', null, null, null],
      [92, '리닝', '할버텍', '할버텍 8000', null, null, null],
      [93, '리닝', '할버텍', '할버텍 7000', null, null, null],
      [94, '리닝', '할버텍', '할버텍 5000', null, null, null],
      [95, '리닝', '할버텍', '할버텍 3000', null, null, null],
      [96, '리닝', '할버텍', '할버텍 2000', null, null, null],
      [97, '리닝', '할버텍', '할버텍 1000', null, null, null],
      [98, '리닝', '윈드스톰', '윈드스톰 72', null, null, null],
      [99, '리닝', '윈드스톰', '윈드스톰 72 POWER', null, null, null],
      [100, '리닝', '윈드스톰', '윈드스톰 72 SPEED', null, null, null],
      [101, '리닝', '윈드스톰', '윈드스톰 79-S', null, null, null],
      [102, '리닝', '윈드스톰', '윈드스톰 79-H', null, null, null],
      [103, 'APACS', 'POWERSTERN', 'POWERSTERN 1000', null, null, null],
      [104, 'APACS', 'HIGHCONZ', 'HIGHCONZ 555', null, null, null],
      [105, 'APACS', 'HIGHCONZ', 'HIGHCONZ 700', null, null, null],
      [106, 'APACS', 'HYPERCORE', 'HYPERCORE 8000', null, null, null],
      [107, 'APACS', 'ULTRIX', 'ULTRIX 66', null, null, null],
      [108, 'APACS', 'ULTRIX', 'ULTRIX 88', null, null, null],
      [109, 'APACS', 'SFRICTION', 'SFRICTION 270', null, null, null],
      [110, 'APACS', 'SFRICTION', 'SFRICTION 7', null, null, null],
      [111, 'APACS', 'CROSS COURT', 'CROSS COURT PRO', null, null, null],
      [112, 'APACS', 'CROSS COURT', 'CROSS COURT POWER', null, null, null],
      [113, 'APACS', 'CROSS COURT', 'CROSS COURT CONTROL', null, null, null],
      [114, 'APACS', 'CROSS COURT', 'CROSS COURT SPEED', null, null, null],
      [115, 'APACS', 'FANTALA', 'FANTALA PRO 101', null, null, null],
      [116, 'APACS', 'HARD HITTER', 'HARD HITTER PRO', null, null, null],
      [117, 'APACS', 'VERSUS', 'VERSUS PRO', null, null, null],
      [118, 'APACS', 'HONOR', 'HONOR PRO', null, null, null],
      [119, 'APACS', 'HONOR', 'HONOR PRO 6.4', null, null, null],
      [120, 'APACS', 'IMPERIAL', 'IMPERIAL PRO', null, null, null],
      [121, 'APACS', 'IMPERIAL', 'IMPERIAL POWER', null, null, null],
      [122, 'APACS', 'BLEND', 'BLEND PRO POWERPLUS', null, null, null],
      [123, 'APACS', 'ASSAILANT', 'ASSAILANT PRO', null, null, null],
      [124, 'APACS', 'ASSAILANT', 'ASSAILANT POWER', null, null, null],
      [125, 'APACS', 'ASSAILANT', 'ASSAILANT CONTROL', null, null, null],
      [126, 'APACS', 'ASSAILANT', 'ASSAILANT SPEED', null, null, null],
      [127, 'APACS', 'BLIZZARD', 'BLIZZARD PRO ZZ', null, null, null],
      [128, 'APACS', 'FEATHER WEIGHT', 'FEATHER WEIGHT 55', null, null, null],
      [129, 'APACS', 'FEATHER WEIGHT', 'FEATHER WEIGHT 75', null, null, null],
      [130, 'APACS', 'FEATHER WEIGHT', 'FEATHER WEIGHT 100', null, null, null],
      [131, 'APACS', 'FEATHER WEIGHT', 'FEATHER WEIGHT 300', null, null, null],
      [132, 'APACS', 'FEATHER WEIGHT', 'FEATHER WEIGHT 500', null, null, null],
      [133, 'APACS', 'WOVEN', 'WOVEN CONTROL', null, null, null],
      [134, 'APACS', 'WOVEN', 'WOVEN POWER', null, null, null],
      [
        135,
        'APACS',
        'NANO FUSION',
        'NANO FUSION SPEED 722 DURA PRO',
        null,
        null,
        null,
      ],
      [136, 'APACS', 'ASGARDIA', 'ASGARDIA LITE', null, null, null],
      [137, 'APACS', 'LETHAL', 'LETHAL 28', null, null, null],
      [138, 'APACS', 'ACCURATE', 'ACCURATE 99', null, null, null],
      [139, 'APACS', 'STARDOM', 'STARDOM 80 II', null, null, null],
      [140, 'APACS', 'VIRTUS', 'VIRTUS 35', null, null, null],
      [141, 'APACS', 'ASTRAL', 'ASTRAL 9000', null, null, null],
      [142, 'APACS', 'LEGACY', 'LEGACY 909', null, null, null],
      [143, 'APACS', 'VALIANT', 'VALIANT 8000', null, null, null],
      [144, 'APACS', 'TRAINING', 'TRAINING RACKET 120', null, null, null],
      [145, 'APACS', 'TRAINING', 'TRAINING RACKET 140', null, null, null],
      [146, 'APACS', 'TRAINING', 'TRAINING RACKET 160', null, null, null],
      [147, 'MIZUNO', 'ACROFORCE', 'ACROFORCE 200', null, null, null],
      [148, 'MIZUNO', 'ACROFORCE', 'ACROFORCE 100', null, null, null],
      [149, 'MIZUNO', 'ACROFORCE', 'ACROFORCE 80', null, null, null],
      [150, 'MIZUNO', 'FORTIUS', 'FORTIUS 20', null, null, null],
      [151, 'MIZUNO', 'FORTIUS', 'FORTIUS 10 POWER', null, null, null],
      [152, 'MIZUNO', 'FORTIUS', 'FORTIUS 10 QUICK', null, null, null],
      [153, 'MIZUNO', 'FORTIUS', 'FORTIUS 60', null, null, null],
      [154, 'MIZUNO', 'FORTIUS', 'FORTIUS 50 SPIRIT', null, null, null],
      [155, 'MIZUNO', 'FORTIUS', 'FORTIUS 30', null, null, null],
      [156, 'MIZUNO', 'ALTIUS', 'ALTIUS N FEEL', null, null, null],
      [157, 'MIZUNO', 'ALTIUS', 'ALTIUS 01 FEEL', null, null, null],
      [158, 'MIZUNO', 'ALTIUS', 'ALTIUS 02 SOLEAR', null, null, null],
      [159, 'MIZUNO', 'ALTIUS', 'ALTIUS 03 FEEL', null, null, null],
      [160, 'MIZUNO', 'ALTIUS', 'ALTIUS 06', null, null, null],
      [161, 'MIZUNO', 'ALTIUS', 'ALTIUS 07 LIGHT', null, null, null],
      [162, 'TECHNIST', 'SPEAR', 'SPEAR 93', null, null, null],
      [163, 'TECHNIST', 'SPEAR', 'SPEAR 94', '3U / 4U', 'EVEN', 'STIFF'],
      [164, 'TECHNIST', 'JH', 'JH-VII', '3U / 4U', 'HEAD LIGHT', 'FLEXIBLE'],
    ];
    for (final row in rackets) {
      await db.rawInsert(
        'INSERT OR IGNORE INTO racket_model VALUES (?, ?, ?, ?, ?, ?, ?)',
        row,
      );
    }
    const shoes = [
      [1, '요넥스', '파워쿠션 65Z', '2E'],
      [2, '요넥스', '에어러스 Z', '2E'],
      [3, '빅터', 'A970', '2.5E'],
      [4, '빅터', 'P9200', '2.5E'],
      [5, '리닝', '레인저 TD', '2E'],
      [6, '리닝', '사가 라이트', '2E'],
      [7, '요넥스', '파워쿠션 65 Z4 MEN', null],
      [8, '요넥스', '파워쿠션 65 Z4 WOMEN', null],
      [9, '요넥스', '파워쿠션 65 Z4 WIDE', '4E'],
      [10, '요넥스', '파워쿠션 이클립션 Z3 MEN', null],
      [11, '요넥스', '파워쿠션 이클립션 Z3 WOMEN', null],
      [12, '요넥스', '파워쿠션 이클립션 Z3 WIDE', '4E'],
      [13, '요넥스', '파워쿠션 에어러스 Z2 MEN', null],
      [14, '요넥스', '파워쿠션 에어러스 Z2 WOMEN', null],
      [15, '요넥스', '파워쿠션 에어러스 Z2 WIDE', '4E'],
      [16, '요넥스', '파워쿠션 컴포트 Z3', null],
      [17, '요넥스', '파워쿠션 캐스케이드 드라이브 2', null],
      [18, '요넥스', '파워쿠션 스트라이더 플로우', null],
      [19, '요넥스', '파워쿠션 스트라이더 플로우 WIDE', '4E'],
      [20, '요넥스', '파워쿠션 인피니티 2', null],
      [21, '요넥스', '서브액시아 GT MEN', null],
      [22, '요넥스', '서브액시아 GT WOMEN', null],
      [23, '빅터', 'P9200 III', null],
      [24, '빅터', 'P9200 TTY', null],
      [25, '빅터', 'P9200 CC', null],
      [26, '빅터', 'P8500 II', null],
      [27, '빅터', 'A970 ACE', null],
      [28, '빅터', 'A970 NITROLITE', null],
      [29, '빅터', 'A830 IV', null],
      [30, '빅터', 'A362 II', null],
      [31, '빅터', 'S82 III', null],
      [32, '빅터', 'S81', null],
      [33, '빅터', 'S70', null],
      [34, '빅터', 'S35', null],
      [35, '빅터', 'VG2 ACE', null],
      [36, '빅터', 'C90N', null],
      [37, '빅터', 'P9310', null],
      [38, '빅터', 'A396', null],
      [39, '리닝', 'YUN TING', null],
      [40, '리닝', 'SAGA II MAX', null],
      [41, '리닝', 'MIRAGE SE', null],
      [42, '리닝', 'BLAST JF LITE', null],
      [43, '리닝', 'BLADE PRO', null],
      [44, '리닝', 'BLADE LITE', null],
      [45, '리닝', 'BLADE II PRO', null],
      [46, '리닝', 'ALMIGHTY V', null],
      [47, '리닝', 'ALMIGHTY V KIDS', null],
      [48, '리닝', 'BLADE II JR.', null],
      [49, '리닝', 'SAGA JR.', null],
      [50, '리닝', 'LEI TING II PRO', null],
      [51, '리닝', 'RANGER TD', null],
      [52, '리닝', 'SAGA LITE', null],
      [53, '리닝', 'ROGUE', null],
      [54, '리닝', 'ATTACK PRO', null],
      [55, 'APACS', 'SP609-YS', null],
      [56, 'APACS', 'CP502-XY', null],
      [57, 'APACS', 'CUSHION CP082', null],
      [58, 'APACS', 'PRO 752', null],
      [59, 'APACS', 'PRO 772', null],
      [60, 'APACS', 'SP608 F-II', null],
      [61, 'APACS', 'PRO 728', null],
      [62, 'APACS', 'PRO 729', null],
      [63, 'APACS', 'AGGRESSIVE 517', null],
      [64, 'APACS', 'CP 256', null],
      [65, 'APACS', 'ADVANTAGE 622', null],
      [66, 'APACS', 'PERFORMANCE 670', null],
      [67, 'MIZUNO', 'WAVE FANG PRO', '2E'],
      [68, 'MIZUNO', 'WAVE FANG ST', null],
      [69, 'MIZUNO', 'WAVE FANG 3 FIT', '2E'],
      [70, 'MIZUNO', 'WAVE FANG 3', '3E'],
      [71, 'MIZUNO', 'WAVE FANG EL 2', null],
      [72, 'MIZUNO', 'WAVE CLAW PRO 3', null],
      [73, 'MIZUNO', 'WAVE CLAW 4 FIT', '2E'],
      [74, 'MIZUNO', 'WAVE CLAW 4', '3E'],
      [75, 'MIZUNO', 'WAVE CLAW 4 WIDE', '4E'],
      [76, 'MIZUNO', 'WAVE CLAW NEO 3 FIT', '2E'],
      [77, 'MIZUNO', 'WAVE CLAW NEO 3', '3E'],
      [78, 'MIZUNO', 'WAVE CLAW EL 2 FIT', '2E'],
      [79, 'MIZUNO', 'WAVE CLAW EL 2', '3E'],
      [80, 'MIZUNO', 'WAVE CLAW EL 2 WIDE', '4E'],
      [81, 'MIZUNO', 'SKY BLASTER 4', null],
      [82, 'MIZUNO', 'MIZUNO ENERZY SLIDE', null],
      [83, 'TECHNIST', 'TECHNIC-99BE+', null],
      [84, 'TECHNIST', 'T950 BOOST PLUS', null],
      [85, 'TECHNIST', 'TECHNIC-99GN+', null],
      [86, 'TECHNIST', 'TECHNIC-99BK+', null],
    ];
    for (final row in shoes) {
      await db.rawInsert(
        'INSERT OR IGNORE INTO shoe_model VALUES (?, ?, ?, ?)',
        row,
      );
    }
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
    return _db.insert(table, {'brand': cleanBrand, 'name': cleanName});
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
