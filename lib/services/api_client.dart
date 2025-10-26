import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _tokenKey = 'auth_token';
  String get baseUrl => AppConfig.apiBase;

  Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_tokenKey, token);
  }
  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
  }
  Future<void> clearToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_tokenKey);
  }

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
    final h = await _headers(headers);
    return http.get(uri, headers: h);
  }
  Future<http.Response> post(String path, {Object? body, Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
    final h = await _headers(headers, json: true);
    return http.post(uri, headers: h, body: jsonEncode(body));
  }
  Future<http.Response> delete(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
    final h = await _headers(headers);
    return http.delete(uri, headers: h);
  }

  Future<http.Response> put(String path, {Object? body, Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
    final h = await _headers(headers, json: true);
    return http.put(uri, headers: h, body: jsonEncode(body));
  }

  Future<Map<String, String>> _headers(Map<String, String>? headers, {bool json = false}) async {
    final token = await getToken();
    final m = <String, String>{};
    if (json) m['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty) m['Authorization'] = 'Bearer $token';
    if (headers != null) m.addAll(headers);
    return m;
  }

  dynamic decodeOrThrow(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }
}
