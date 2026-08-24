import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/workout_record.dart';
import 'api_client.dart';

/// 운동 기록 API 호출
class RecordApi {
  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static dynamic _decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  /// 실패 응답의 message를 꺼내 예외로 던진다
  static Never _throwError(http.Response response, String fallback) {
    String message = fallback;
    try {
      final body = _decode(response);
      message = (body['message'] as String?) ?? fallback;
    } catch (_) {}
    throw Exception(message);
  }

  /// 한 달치 기록
  static Future<List<WorkoutRecord>> fetchMonth(int year, int month) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/api/records?year=$year&month=$month'),
      headers: ApiClient.authJsonHeaders,
    );
    if (response.statusCode != 200) {
      _throwError(response, '기록을 불러오지 못했습니다.');
    }
    return (_decode(response) as List)
        .map((e) => WorkoutRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> create({
    required DateTime date,
    required String type, // 'GENERAL', 'LESSON', 'TOURNAMENT'
    required String title,
    String? place,
    String? coach,
    String? result,
    String? memo,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/api/records'),
      headers: ApiClient.authJsonHeaders,
      body: jsonEncode({
        'date': _iso(date),
        'type': type,
        'title': title,
        if (place != null && place.isNotEmpty) 'place': place,
        if (coach != null && coach.isNotEmpty) 'coach': coach,
        if (result != null && result.isNotEmpty) 'result': result,
        if (memo != null && memo.isNotEmpty) 'memo': memo,
      }),
    );
    if (response.statusCode != 201) {
      _throwError(response, '기록 저장에 실패했습니다.');
    }
  }

  static Future<void> delete(int recordId) async {
    final response = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/api/records/$recordId'),
      headers: ApiClient.authJsonHeaders,
    );
    if (response.statusCode != 204) {
      _throwError(response, '기록 삭제에 실패했습니다.');
    }
  }
}
