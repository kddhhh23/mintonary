import 'package:flutter_test/flutter_test.dart';
import 'package:mintonary/data/local_database.dart';
import 'package:mintonary/models/expense.dart';

import '../helpers/test_database.dart';

void main() {
  late LocalDatabase database;

  setUp(() async => database = await openTestDatabase());
  tearDown(() => database.close());

  group('장비 모델 카탈로그', () {
    test('기본 카탈로그의 개수, 대표 모델, 중복 여부를 검증한다', () async {
      final rackets = await database.fetchRacketModels();
      final shoes = await database.fetchShoeModels();

      expect(rackets, hasLength(243));
      expect(shoes, hasLength(86));
      expect(
        rackets.any(
          (model) => model.brand == '빅터' && model.name == '브레이브소드 12',
        ),
        isTrue,
      );
      expect(rackets.any((model) => model.brand == '요넥스'), isTrue);
      expect(rackets.any((model) => model.brand == '아펙스'), isTrue);
      expect(rackets.any((model) => model.brand == '미즈노'), isTrue);
      expect(rackets.any((model) => model.brand == '테크니스트'), isTrue);

      final racketKeys = rackets
          .map(
            (model) =>
                '${model.brand.toLowerCase()}|${model.name.toLowerCase()}',
          )
          .toSet();
      final shoeKeys = shoes
          .map(
            (model) =>
                '${model.brand.toLowerCase()}|${model.name.toLowerCase()}',
          )
          .toSet();
      expect(racketKeys, hasLength(rackets.length));
      expect(shoeKeys, hasLength(shoes.length));
    });

    test('직접 입력 모델은 공백을 정리하고 대소문자 중복을 재사용한다', () async {
      final firstId = await database.addCustomModel(
        type: 'RACKET',
        brand: '  Test Brand  ',
        name: '  Custom One  ',
      );
      final duplicateId = await database.addCustomModel(
        type: 'RACKET',
        brand: 'test brand',
        name: 'custom one',
      );

      expect(duplicateId, firstId);
      final models = await database.fetchRacketModels();
      expect(
        models.where((model) => model.id == firstId).single.brand,
        'Test Brand',
      );
      expect(
        database.addCustomModel(type: 'RACKET', brand: ' ', name: '모델'),
        throwsException,
      );
      expect(
        database.addCustomModel(type: 'UNKNOWN', brand: 'A', name: 'B'),
        throwsArgumentError,
      );
    });
  });

  group('장비 관리', () {
    test('라켓 등록부터 이력, 알림, 상태, 수정, 삭제까지 동작한다', () async {
      final models = await database.fetchRacketModels();
      final model = models.firstWhere(
        (item) => item.brand == '빅터' && item.name == '브레이브소드 12',
      );

      await database.register(
        type: 'RACKET',
        modelId: model.id,
        purchaseDate: DateTime(2026, 8, 10),
        price: 180000,
        addToExpenses: true,
        stringName: 'BG80',
        tension: 27,
        strungAt: DateTime(2026, 8, 11),
        gripName: 'AC102EX',
        gripType: 'OVER',
        wrappedAt: DateTime(2026, 8, 12),
      );

      var list = await database.fetchEquipments();
      expect(list.rackets, hasLength(1));
      expect(list.shoes, isEmpty);
      final equipmentId = list.rackets.single.id;
      expect(list.rackets.single.stringName, 'BG80');
      expect(list.rackets.single.tension, 27);
      expect(list.rackets.single.gripName, 'AC102EX');
      expect(list.rackets.single.inUse, isTrue);

      final expense = await database.fetchExpenseMonth(2026, 8);
      expect(expense.totalAmount, 180000);
      expect(expense.expenses.single.category, ExpenseCategory.equipment);
      expect(expense.expenses.single.title, '빅터 브레이브소드 12');
      expect(expense.expenses.single.memo, isNull);

      await database.addStringChange(
        equipmentId,
        name: 'EXBOLT 65',
        tension: 28,
        strungAt: DateTime(2026, 9, 1),
      );
      await database.addGripChange(
        equipmentId,
        name: '타월 그립',
        type: 'TOWEL',
        wrappedAt: DateTime(2026, 9, 2),
      );
      await database.setStringAlarm(equipmentId, DateTime(2026, 10, 1));

      var detail = await database.fetchDetail(equipmentId);
      expect(detail.racket?.stringHistories, hasLength(2));
      expect(detail.racket?.stringHistories.first.name, 'EXBOLT 65');
      expect(detail.racket?.gripHistories, hasLength(2));
      expect(detail.racket?.gripHistories.first.name, '타월 그립');
      expect(detail.racket?.stringAlarmDate, DateTime(2026, 10, 1));

      await database.deleteStringChange(
        equipmentId,
        detail.racket!.stringHistories.first.id,
      );
      await database.deleteGripChange(
        equipmentId,
        detail.racket!.gripHistories.first.id,
      );
      await database.setStringAlarm(equipmentId, null);

      final replacement = models.firstWhere((item) => item.id != model.id);
      await database.updateEquipment(
        equipmentId,
        modelId: replacement.id,
        purchaseDate: DateTime(2026, 8, 15),
        price: 170000,
        memo: '  서브 라켓  ',
      );
      await database.setStatus(equipmentId, false);

      detail = await database.fetchDetail(equipmentId);
      expect(detail.racket?.name, replacement.name);
      expect(detail.purchaseDate, DateTime(2026, 8, 15));
      expect(detail.price, 170000);
      expect(detail.memo, '서브 라켓');
      expect(detail.inUse, isFalse);
      expect(detail.racket?.stringAlarmDate, isNull);
      expect(detail.racket?.stringHistories, hasLength(1));
      expect(detail.racket?.gripHistories, hasLength(1));

      await database.setStatus(equipmentId, true);
      expect((await database.fetchDetail(equipmentId)).inUse, isTrue);

      await database.deleteEquipment(equipmentId);
      list = await database.fetchEquipments();
      expect(list.rackets, isEmpty);
      expect(database.fetchDetail(equipmentId), throwsException);
    });

    test('신발은 라켓 정보 없이 등록되고 지출 추가는 선택 사항이다', () async {
      final model = (await database.fetchShoeModels()).first;
      await database.register(
        type: 'SHOE',
        modelId: model.id,
        purchaseDate: DateTime(2026, 9, 1),
        price: 120000,
        addToExpenses: false,
      );

      final list = await database.fetchEquipments();
      expect(list.rackets, isEmpty);
      expect(list.shoes, hasLength(1));
      final detail = await database.fetchDetail(list.shoes.single.id);
      expect(detail.type, 'SHOE');
      expect(detail.racket, isNull);
      expect(detail.shoe, isNotNull);
      expect((await database.fetchExpenseMonth(2026, 9)).expenses, isEmpty);
    });

    test('잘못된 장비 종류나 존재하지 않는 모델은 저장하지 않는다', () async {
      expect(
        database.register(type: 'UNKNOWN', modelId: 1),
        throwsArgumentError,
      );
      expect(
        database.register(type: 'RACKET', modelId: 999999),
        throwsException,
      );

      final list = await database.fetchEquipments();
      expect(list.rackets, isEmpty);
      expect(list.shoes, isEmpty);
    });
  });
}
