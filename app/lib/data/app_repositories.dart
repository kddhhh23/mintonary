import 'local_database.dart';
import 'repositories.dart';

class AppRepositories {
  AppRepositories._();

  static late ProfileRepository profile;
  static late RecordRepository records;
  static late ExpenseRepository expenses;
  static late EquipmentRepository equipment;

  static Future<void> initialize() async {
    final database = await LocalDatabase.open();
    profile = database;
    records = database;
    expenses = database;
    equipment = database;
  }
}
