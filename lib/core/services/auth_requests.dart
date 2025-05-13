import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
final apiUrl = Uri.parse('http://localhost:8080');

Future<Map<String, dynamic>> login(String email, String senha) async {
  final loginUrl = Uri.parse('$apiUrl/auth/login');
  final headers = {'Content-Type': 'application/json'};

  final body = json.encode({
    'email': email,
    'senha': senha,
  });

  try {
    final response = await http.post(loginUrl, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['token'] != null) {
        await storage.write(key: 'token', value: responseData['token']);
      }
      return responseData;
    } else {
      return {'error': 'Email ou senha incorretos'};
    }
  } catch (e) {
    return {'error': 'Falha ao conectar com a API'};
  }
}

Future<http.Response> makeAuthenticatedRequest(
    String endpoint, Map<String, dynamic> body) async {
  final token = await storage.read(key: 'token');
  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  final apiUrl = Uri.parse('http://159.203.172.72:8080/$endpoint');
  return await http.post(apiUrl, headers: headers, body: json.encode(body));
}

Future<void> logout() async {
  await storage.delete(key: 'token');
}