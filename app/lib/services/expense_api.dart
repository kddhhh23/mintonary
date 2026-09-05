import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/expense.dart';
import 'api_client.dart';

class ExpenseApi {
  static String _iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static dynamic _decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  static Never _throwError(http.Response response, String fallback) {
    var message = fallback;
    try {
      final body = _decode(response);
      message = (body['message'] as String?) ?? fallback;
    } catch (_) {}
    throw Exception(message);
  }

  static Future<ExpenseMonth> fetchMonth(int year, int month) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/api/expenses?year=$year&month=$month'),
      headers: ApiClient.authJsonHeaders,
    );
    if (response.statusCode != 200) {
      _throwError(response, '지출 내역을 불러오지 못했습니다.');
    }
    return ExpenseMonth.fromJson(_decode(response) as Map<String, dynamic>);
  }

  static Future<void> create({
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  }) => _save(
    date: date,
    category: category,
    title: title,
    amount: amount,
    memo: memo,
  );

  static Future<void> update(
    int id, {
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  }) => _save(
    id: id,
    date: date,
    category: category,
    title: title,
    amount: amount,
    memo: memo,
  );

  static Future<void> _save({
    int? id,
    required DateTime date,
    required ExpenseCategory category,
    required String title,
    required int amount,
    String? memo,
  }) async {
    final uri = Uri.parse(
      id == null
          ? '${ApiClient.baseUrl}/api/expenses'
          : '${ApiClient.baseUrl}/api/expenses/$id',
    );
    final body = jsonEncode({
      'date': _iso(date),
      'category': category.serverValue,
      'title': title,
      'amount': amount,
      if (memo != null && memo.isNotEmpty) 'memo': memo,
    });
    final response = id == null
        ? await http.post(uri, headers: ApiClient.authJsonHeaders, body: body)
        : await http.patch(uri, headers: ApiClient.authJsonHeaders, body: body);
    final expected = id == null ? 201 : 204;
    if (response.statusCode != expected) {
      _throwError(response, id == null ? '지출 등록에 실패했습니다.' : '지출 수정에 실패했습니다.');
    }
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/api/expenses/$id'),
      headers: ApiClient.authJsonHeaders,
    );
    if (response.statusCode != 204) {
      _throwError(response, '지출 삭제에 실패했습니다.');
    }
  }
}
