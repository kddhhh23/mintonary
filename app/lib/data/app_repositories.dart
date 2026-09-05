import 'local_database.dart';
import 'remote_repositories.dart';
import 'repositories.dart';

class AppRepositories {
  AppRepositories._();

  static late ProfileRepository profile;
  static late RecordRepository records;
  static late ExpenseRepository expenses;
  static late EquipmentRepository equipment;

  static Future<void> initialize() async {
    if (storageMode == StorageMode.local) {
      final database = await LocalDatabase.open();
      profile = database;
      records = database;
      expenses = database;
      equipment = database;
      return;
    }
    profile = UnsupportedRemoteProfileRepository();
    records = RemoteRecordRepository();
    expenses = RemoteExpenseRepository();
    equipment = RemoteEquipmentRepository();
  }
}
