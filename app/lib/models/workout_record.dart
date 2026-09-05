/// 운동 기록 모델
class WorkoutRecord {
  const WorkoutRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    this.place,
    this.coach,
    this.result,
    this.memo,
  });

  final int id;
  final DateTime date;

  /// GENERAL, LESSON, TOURNAMENT
  final String type;
  final String title;
  final String? place;
  final String? coach;

  /// 대회 결과 (예: 준우승)
  final String? result;
  final String? memo;
}
