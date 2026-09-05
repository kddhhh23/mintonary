import 'package:flutter_test/flutter_test.dart';
import 'package:mintonary/data/local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

bool _ffiInitialized = false;

Future<LocalDatabase> openTestDatabase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (!_ffiInitialized) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _ffiInitialized = true;
  }
  return LocalDatabase.open(databasePath: inMemoryDatabasePath);
}
