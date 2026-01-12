import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../config.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient({required TokenStorage tokenStorage, http.Client? httpClient})
      : _tokenStorage = tokenStorage,
        _http = httpClient ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _http;

  Uri _u(String path, [Map<String, String>? query]) {
    return Uri.parse('$kApiBaseUrl$path').replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers({bool jsonBody = true}) async {
    final token = await _tokenStorage.read();
    final headers = <String, String>{'Accept': 'application/json'};
    if (jsonBody) headers['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Map<String, dynamic> _decodeJson(http.Response res) {
    if (res.statusCode == 413) {
      return {
        'message': 'Upload terlalu besar (413). Coba ulang dengan foto yang lebih kecil.',
        'status': res.statusCode,
        'content_type': res.headers['content-type'],
      };
    }
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'message': 'Unexpected JSON shape', 'body': decoded};
    } on FormatException {
      final contentType = res.headers['content-type'];
      final bodyPreview = res.body.length > 500 ? '${res.body.substring(0, 500)}…' : res.body;
      return {
        'message': 'Invalid JSON response',
        'status': res.statusCode,
        'content_type': contentType,
        'body_preview': bodyPreview,
      };
    }
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final res = await _http.post(_u(path), headers: await _headers(), body: jsonEncode(body));
    final decoded = _decodeJson(res);
    if (res.statusCode >= 400) throw ApiException(decoded, res.statusCode);
    if (decoded['message'] == 'Invalid JSON response') throw ApiException(decoded, res.statusCode);
    return decoded;
  }

  Future<Map<String, dynamic>> getJson(String path, {Map<String, String>? query}) async {
    final res = await _http.get(_u(path, query), headers: await _headers(jsonBody: false));
    final decoded = _decodeJson(res);
    if (res.statusCode >= 400) throw ApiException(decoded, res.statusCode);
    if (decoded['message'] == 'Invalid JSON response') throw ApiException(decoded, res.statusCode);
    return decoded;
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    Map<String, File?>? files,
    Map<String, List<String>>? listFields,
  }) async {
    final req = http.MultipartRequest('POST', _u(path));
    req.headers.addAll(await _headers(jsonBody: false));
    req.fields.addAll(fields);

    if (listFields != null) {
      for (final entry in listFields.entries) {
        for (var i = 0; i < entry.value.length; i++) {
          req.fields['${entry.key}[$i]'] = entry.value[i];
        }
      }
    }

    if (files != null) {
      for (final entry in files.entries) {
        final f = entry.value;
        if (f == null) continue;
        req.files.add(await http.MultipartFile.fromPath(entry.key, f.path));
      }
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    final decoded = _decodeJson(res);
    if (res.statusCode >= 400) throw ApiException(decoded, res.statusCode);
    if (decoded['message'] == 'Invalid JSON response') throw ApiException(decoded, res.statusCode);
    return decoded;
  }
}

class ApiException implements Exception {
  ApiException(this.body, this.statusCode);
  final Map<String, dynamic> body;
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
