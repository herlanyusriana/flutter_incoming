import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository({required ApiClient apiClient, required TokenStorage tokenStorage})
      : _api = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient _api;
  final TokenStorage _tokenStorage;

  Future<String?> getToken() => _tokenStorage.read();

  Future<void> login({required String email, required String password, String? deviceName}) async {
    try {
      final res = await _api.postJson('/api/auth/login', {
        'email': email,
        'password': password,
        'device_name': deviceName ?? 'android',
      });
      final token = res['token'] as String;
      await _tokenStorage.write(token);
    } on ApiException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<void> logout() async {
    await _api.postJson('/api/auth/logout', {});
    await _tokenStorage.clear();
  }

  String _friendlyMessage(ApiException e) {
    final message = e.body['message'];
    if (message is String && message.trim().isNotEmpty) return message.trim();

    final errors = e.body['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty && value.first is String) {
          return (value.first as String).trim();
        }
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }

    return 'Login gagal (HTTP ${e.statusCode}).';
  }
}
