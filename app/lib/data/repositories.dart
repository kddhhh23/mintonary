import '../models/equipment.dart';
import '../models/expense.dart';
import '../models/workout_record.dart';

enum StorageMode { local, remote }

const storageMode = StorageMode.local;

class LocalProfile {
  const LocalProfile({
    required this.nickname,
    this.email,
    this.birthDate,
    this.gender,
    this.localClass,
    this.nationalClass,
  });

  final String nickname;
  final String? email;
  final DateTime? birthDate;
  final String? gender;
  final String? localClass;
  final String? nationalClass;
}

abstract interface class ProfileRepository {
  Future<LocalProfile?> load();
  Future<void> save(LocalProfile profile);
}

abstract interface class RecordRepository {
  Future<List<WorkoutRecord>> fetchRecordMonth(int year, int month);
  Future<void> createRecord({
    required DateTime date,
    required String type,
    required String title,
    String? place,
    String? coach,
    String? result,
    String? memo,
  });
  Future<void> updateRecord(
    int id, {
    required DateTime date,
    required String type,
    required String title,
    String? place,
    String? coach,
    String? result,
    String? memo,
  });
  Future<void> deleteRecord(int id);
}

abstract interface class ExpenseRepository {
  Future<ExpenseMonth> fetchExpenseMonth(int year, int month);
  Future<void> createExpense({
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  });
  Future<void> updateExpense(
    int id, {
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  });
  Future<void> deleteExpense(int id);
}

abstract interface class EquipmentRepository {
  Future<List<RacketModelOption>> fetchRacketModels();
  Future<List<ShoeModelOption>> fetchShoeModels();
  Future<int> addCustomModel({
    required String type,
    required String brand,
    required String name,
  });
  Future<EquipmentList> fetchEquipments();
  Future<EquipmentDetail> fetchDetail(int id);
  Future<void> register({
    required String type,
    required int modelId,
    DateTime? purchaseDate,
    int? price,
    bool addToExpenses,
    String? stringName,
    int? tension,
    DateTime? strungAt,
    String? gripName,
    String? gripType,
    DateTime? wrappedAt,
  });
  Future<void> updateEquipment(
    int equipmentId, {
    required int modelId,
    DateTime? purchaseDate,
    int? price,
    String? memo,
  });
  Future<void> deleteEquipment(int equipmentId);
  Future<void> addStringChange(
    int equipmentId, {
    required String name,
    int? tension,
    required DateTime strungAt,
  });
  Future<void> deleteStringChange(int equipmentId, int historyId);
  Future<void> addGripChange(
    int equipmentId, {
    required String name,
    required String type,
    required DateTime wrappedAt,
  });
  Future<void> deleteGripChange(int equipmentId, int historyId);
  Future<void> setStringAlarm(int equipmentId, DateTime? date);
  Future<void> setStatus(int equipmentId, bool inUse);
}
