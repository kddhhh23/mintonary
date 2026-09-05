import 'package:flutter_test/flutter_test.dart';
import 'package:mintonary/data/local_database.dart';
import 'package:mintonary/data/repositories.dart';

import '../helpers/test_database.dart';

void main() {
  late LocalDatabase database;

  setUp(() async => database = await openTestDatabase());
  tearDown(() => database.close());

  group('프로필 저장소', () {
    test('최초에는 프로필이 없고 저장 후 모든 항목을 복원한다', () async {
      expect(await database.load(), isNull);

      await database.save(
        LocalProfile(
          nickname: '민턴이',
          email: 'player@example.com',
          birthDate: DateTime(1998, 3, 12),
          gender: 'FEMALE',
          localClass: 'B',
          nationalClass: 'C',
        ),
      );

      final profile = await database.load();
      expect(profile?.nickname, '민턴이');
      expect(profile?.email, 'player@example.com');
      expect(profile?.birthDate, DateTime(1998, 3, 12));
      expect(profile?.gender, 'FEMALE');
      expect(profile?.localClass, 'B');
      expect(profile?.nationalClass, 'C');
    });

    test('두 번째 저장은 기존 단일 프로필을 교체한다', () async {
      await database.save(const LocalProfile(nickname: '기존'));
      await database.save(const LocalProfile(nickname: '수정', localClass: 'A'));

      final profile = await database.load();
      expect(profile?.nickname, '수정');
      expect(profile?.localClass, 'A');
      expect(profile?.email, isNull);
    });
  });

  group('운동 기록 저장소', () {
    test('월별 조회, 날짜 정렬, 생성, 수정, 삭제가 동작한다', () async {
      await database.createRecord(
        date: DateTime(2026, 9, 20),
        type: 'GENERAL',
        title: '클럽 운동',
        place: '체육관',
      );
      await database.createRecord(
        date: DateTime(2026, 9, 2),
        type: 'LESSON',
        title: '레슨',
        coach: '김 코치',
      );
      await database.createRecord(
        date: DateTime(2026, 10, 1),
        type: 'TOURNAMENT',
        title: '다음 달 대회',
      );

      var september = await database.fetchRecordMonth(2026, 9);
      expect(september, hasLength(2));
      expect(september.map((record) => record.title), ['레슨', '클럽 운동']);
      expect(await database.fetchRecordMonth(2026, 8), isEmpty);

      final targetId = september.first.id;
      await database.updateRecord(
        targetId,
        date: DateTime(2026, 9, 3),
        type: 'TOURNAMENT',
        title: '  지역 대회  ',
        place: '  잠실 체육관  ',
        coach: '   ',
        result: '준우승',
        memo: '',
      );

      september = await database.fetchRecordMonth(2026, 9);
      final updated = september.firstWhere((record) => record.id == targetId);
      expect(updated.date, DateTime(2026, 9, 3));
      expect(updated.type, 'TOURNAMENT');
      expect(updated.title, '지역 대회');
      expect(updated.place, '잠실 체육관');
      expect(updated.coach, isNull);
      expect(updated.result, '준우승');
      expect(updated.memo, isNull);

      await database.deleteRecord(targetId);
      september = await database.fetchRecordMonth(2026, 9);
      expect(september, hasLength(1));
      expect(september.single.title, '클럽 운동');
    });

    test('존재하지 않는 운동 기록 수정은 실패한다', () async {
      expect(
        database.updateRecord(
          99999,
          date: DateTime(2026, 9, 1),
          type: 'GENERAL',
          title: '없는 기록',
        ),
        throwsException,
      );
    });
  });
}
