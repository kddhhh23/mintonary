import '../models/equipment.dart';
import '../models/expense.dart';
import '../models/workout_record.dart';
import '../services/equipment_api.dart';
import '../services/expense_api.dart';
import '../services/record_api.dart';
import 'repositories.dart';

class RemoteRecordRepository implements RecordRepository {
  @override
  Future<List<WorkoutRecord>> fetchRecordMonth(int year, int month) =>
      RecordApi.fetchMonth(year, month);
  @override
  Future<void> createRecord({
    required DateTime date,
    required String type,
    required String title,
    String? place,
    String? coach,
    String? result,
    String? memo,
  }) => RecordApi.create(
    date: date,
    type: type,
    title: title,
    place: place,
    coach: coach,
    result: result,
    memo: memo,
  );
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
  }) => throw UnsupportedError('서버 모드에서는 운동 기록 수정을 지원하지 않습니다.');
  @override
  Future<void> deleteRecord(int id) => RecordApi.delete(id);
}

class RemoteExpenseRepository implements ExpenseRepository {
  @override
  Future<ExpenseMonth> fetchExpenseMonth(int year, int month) =>
      ExpenseApi.fetchMonth(year, month);
  @override
  Future<void> createExpense({
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  }) => ExpenseApi.create(
    date: date,
    category: category,
    title: title,
    amount: amount,
    memo: memo,
  );
  @override
  Future<void> updateExpense(
    int id, {
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  }) => ExpenseApi.update(
    id,
    date: date,
    category: category,
    title: title,
    amount: amount,
    memo: memo,
  );
  @override
  Future<void> deleteExpense(int id) => ExpenseApi.delete(id);
}

class RemoteEquipmentRepository implements EquipmentRepository {
  @override
  Future<List<RacketModelOption>> fetchRacketModels() =>
      EquipmentApi.fetchRacketModels();
  @override
  Future<List<ShoeModelOption>> fetchShoeModels() =>
      EquipmentApi.fetchShoeModels();
  @override
  Future<int> addCustomModel({
    required String type,
    required String brand,
    required String name,
  }) => throw UnsupportedError('서버 모드에서는 장비 모델 직접 입력을 지원하지 않습니다.');
  @override
  Future<EquipmentList> fetchEquipments() => EquipmentApi.fetchEquipments();
  @override
  Future<EquipmentDetail> fetchDetail(int id) => EquipmentApi.fetchDetail(id);
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
  }) => EquipmentApi.register(
    type: type,
    modelId: modelId,
    purchaseDate: purchaseDate,
    price: price,
    addToExpenses: addToExpenses,
    stringName: stringName,
    tension: tension,
    strungAt: strungAt,
    gripName: gripName,
    gripType: gripType,
    wrappedAt: wrappedAt,
  );
  @override
  Future<void> updateEquipment(
    int equipmentId, {
    required int modelId,
    DateTime? purchaseDate,
    int? price,
    String? memo,
  }) => throw UnsupportedError('서버 모드에서는 장비 수정을 지원하지 않습니다.');
  @override
  Future<void> deleteEquipment(int equipmentId) =>
      EquipmentApi.delete(equipmentId);
  @override
  Future<void> addStringChange(
    int equipmentId, {
    required String name,
    int? tension,
    required DateTime strungAt,
  }) => EquipmentApi.addStringChange(
    equipmentId,
    name: name,
    tension: tension,
    strungAt: strungAt,
  );
  @override
  Future<void> deleteStringChange(int equipmentId, int historyId) =>
      EquipmentApi.deleteStringChange(equipmentId, historyId);
  @override
  Future<void> addGripChange(
    int equipmentId, {
    required String name,
    required String type,
    required DateTime wrappedAt,
  }) => EquipmentApi.addGripChange(
    equipmentId,
    name: name,
    type: type,
    wrappedAt: wrappedAt,
  );
  @override
  Future<void> deleteGripChange(int equipmentId, int historyId) =>
      EquipmentApi.deleteGripChange(equipmentId, historyId);
  @override
  Future<void> setStringAlarm(int equipmentId, DateTime? date) =>
      EquipmentApi.setStringAlarm(equipmentId, date);
  @override
  Future<void> setStatus(int equipmentId, bool inUse) =>
      EquipmentApi.setStatus(equipmentId, inUse);
}

class UnsupportedRemoteProfileRepository implements ProfileRepository {
  @override
  Future<LocalProfile?> load() async => null;
  @override
  Future<void> save(LocalProfile profile) =>
      throw UnsupportedError('원격 프로필은 로그인 API를 사용합니다.');
}
