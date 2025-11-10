import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
final apiUrl = Uri.parse(
  'https://www.celc.org.br/_functions',
); // Usando o proxy local

Future<List<dynamic>> getDebitos() async {
  final url = Uri.parse('$apiUrl/listarDebitosLivraria'); // ajuste apiUrl
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http
        .get(url, headers: headers)
        .timeout(
          const Duration(seconds: 15),
        ); // evita ficar esperando pra sempre

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Caso o servidor retorne { "result": [ ... ] }
      if (data is Map<String, dynamic> && data['result'] is List) {
        return List<dynamic>.from(data['result']);
      }

      // Caso retorne diretamente uma lista: [ ... ]
      if (data is List) {
        return List<dynamic>.from(data);
      }

      // formato inesperado -> retorna lista vazia
      return [];
    } else {
      // status != 200
      // opcional: decodificar e logar mensagem de erro do servidor
      // final err = jsonDecode(response.body);
      return [];
    }
  } catch (e) {
    // log do erro se quiser: print('getDebitos error: $e');
    return [];
  }
}

Future<List<dynamic>> getDebitosData() async {
  // Exemplo de data esperada: "2025-10-10"
  final url = Uri.parse('$apiUrl/listarDebitosLivrariaData');
  String? token = await storage.read(key: 'token');

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  try {
    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final dataResponse = jsonDecode(response.body);

      // Se o servidor retorna { result: [...] }
      if (dataResponse is Map<String, dynamic> &&
          dataResponse['result'] is List) {
        return List<dynamic>.from(dataResponse['result']);
      }

      // Se retorna diretamente uma lista
      if (dataResponse is List) {
        return List<dynamic>.from(dataResponse);
      }

      return [];
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}
