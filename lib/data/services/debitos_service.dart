import 'dart:convert';
import 'package:celc_app/core/utils/utils.dart';
import 'package:http/http.dart' as http;

class DebitosService {
  Future<List<dynamic>> getDebitos() async {
    final url = Uri.parse(
      Utils.endpoint('listarDebitosLivraria'),
    ); // ajuste apiUrl

    try {
      final response = await http
          .get(url, headers: await Utils.getHeaders())
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
    final url = Uri.parse(Utils.endpoint('listarDebitosLivrariaData'));

    try {
      final response = await http
          .get(url, headers: await Utils.getHeaders())
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

  Future<Map<String, dynamic>> getTotaisDebitos() async {
    final url = Uri.parse(Utils.endpoint('totaisDebitos'));

    try {
      final response = await http
          .get(url, headers: await Utils.getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data;
      } else {
        print("Houve um erro ao carregar os totais de débitos.");
        return {};
      }
    } catch (e) {
      print("Houve um erro ao carregar os totais de débitos.");
      return {};
    }
  }
}
