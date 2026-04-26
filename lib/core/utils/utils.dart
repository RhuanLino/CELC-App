import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Utils {
  static const String baseUrl = 'https://www.celc.org.br/_functions';

  static const _storage = FlutterSecureStorage();

  static String endpoint(String path) {
    return '$baseUrl/$path';
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
