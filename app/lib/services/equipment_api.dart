import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/equipment.dart';
import 'api_client.dart';

/// 장비 API 호출
class EquipmentApi {
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

  static Future<List<RacketModelOption>> fetchRacketModels() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/api/racket-models'),
      headers: ApiClient.authJsonHeaders,
    );
    if (response.statusCode != 200) {
      _throwError(response, '라켓 모델을 불러오지 못했습니다.');
    }
    return (_decode(response) as List)
        .map((e) => RacketModelOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ShoeModelOption>> fetchShoeModels() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/api/shoe-models'),
      headers: ApiClient.authJsonHeaders,
    );
    if (response.statusCode != 200) {
      _throwError(response, '신발 모델을 불러오지 못했습니다.');
    }
    return (_decode(response) as List)
        .map((e) => ShoeModelOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<EquipmentList> fetchEquipments() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/api/equipments'),
      headers: ApiClient.authJsonHeaders,
    );
    if (response.statusCode != 200) {
      _throwError(response, '장비 목록을 불러오지 못했습니다.');
    }
    return EquipmentList.fromJson(_decode(response) as Map<String, dynamic>);
  }

  static Future<EquipmentDetail> fetchDetail(int equipmentId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/api/equipments/$equipmentId'),
      headers: ApiClient.authJsonHeaders,
    );
    if (response.statusCode != 200) {
      _throwError(response, '장비 정보를 불러오지 못했습니다.');
    }
    return EquipmentDetail.fromJson(_decode(response) as Map<String, dynamic>);
  }

  /// 장비 등록 — 라켓이면 스트링/그립 초기 기록을 함께 보낼 수 있다
  static Future<void> register({
    required String type, // 'RACKET' 또는 'SHOE'
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
  }) async {
    final payload = {
      'type': type,
      'modelId': modelId,
      if (purchaseDate != null) 'purchaseDate': _iso(purchaseDate),
      'price': ?price,
      'addToExpenses': addToExpenses,
      if (stringName != null && stringName.isNotEmpty)
        'string': {
          'name': stringName,
          'tension': ?tension,
          if (strungAt != null) 'strungAt': _iso(strungAt),
        },
      if (gripName != null && gripName.isNotEmpty && gripType != null)
        'grip': {
          'name': gripName,
          'type': gripType,
          if (wrappedAt != null) 'wrappedAt': _iso(wrappedAt),
        },
    };

    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/api/equipments'),
      headers: ApiClient.authJsonHeaders,
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      _throwError(response, '장비 등록에 실패했습니다.');
    }
  }

  static Future<void> addStringChange(
    int equipmentId, {
    required String name,
    int? tension,
    required DateTime strungAt,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiClient.baseUrl}/api/equipments/$equipmentId/string-changes',
      ),
      headers: ApiClient.authJsonHeaders,
      body: jsonEncode({
        'name': name,
        'tension': ?tension,
        'strungAt': _iso(strungAt),
      }),
    );
    if (response.statusCode != 201) {
      _throwError(response, '스트링 교체 기록에 실패했습니다.');
    }
  }

  static Future<void> deleteStringChange(int equipmentId, int historyId) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiClient.baseUrl}/api/equipments/$equipmentId/string-changes/$historyId',
      ),
      headers: ApiClient.authJsonHeaders,
    );
    if (response.statusCode != 204) {
      _throwError(response, '교체 이력 삭제에 실패했습니다.');
    }
  }

  static Future<void> addGripChange(
    int equipmentId, {
    required String name,
    required String type, // 'OVER', 'TOWEL', 'CUSHION'
    required DateTime wrappedAt,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiClient.baseUrl}/api/equipments/$equipmentId/grip-changes',
      ),
      headers: ApiClient.authJsonHeaders,
      body: jsonEncode({
        'name': name,
        'type': type,
        'wrappedAt': _iso(wrappedAt),
      }),
    );
    if (response.statusCode != 201) {
      _throwError(response, '그립 교체 기록에 실패했습니다.');
    }
  }

  static Future<void> deleteGripChange(int equipmentId, int historyId) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiClient.baseUrl}/api/equipments/$equipmentId/grip-changes/$historyId',
      ),
      headers: ApiClient.authJsonHeaders,
    );
    if (response.statusCode != 204) {
      _throwError(response, '교체 이력 삭제에 실패했습니다.');
    }
  }

  /// 알림 날짜 변경 — null이면 알림 해제
  static Future<void> setStringAlarm(int equipmentId, DateTime? date) async {
    final response = await http.patch(
      Uri.parse(
        '${ApiClient.baseUrl}/api/equipments/$equipmentId/string-alarm',
      ),
      headers: ApiClient.authJsonHeaders,
      body: jsonEncode({'alarmDate': date == null ? null : _iso(date)}),
    );
    if (response.statusCode != 204) {
      _throwError(response, '알림 날짜 변경에 실패했습니다.');
    }
  }

  static Future<void> setStatus(int equipmentId, bool inUse) async {
    final response = await http.patch(
      Uri.parse('${ApiClient.baseUrl}/api/equipments/$equipmentId/status'),
      headers: ApiClient.authJsonHeaders,
      body: jsonEncode({'inUse': inUse}),
    );
    if (response.statusCode != 204) {
      _throwError(response, '사용 상태 변경에 실패했습니다.');
    }
  }
}
