/// 운동 기록 API 응답 모델
class WorkoutRecord {
  WorkoutRecord.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      date = DateTime.parse(json['date'] as String),
      type = json['type'] as String,
      title = json['title'] as String,
      place = json['place'] as String?,
      coach = json['coach'] as String?,
      result = json['result'] as String?,
      memo = json['memo'] as String?;

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
