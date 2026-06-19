import 'dart:convert';
import 'package:celc_app/core/utils/utils.dart';
import 'package:celc_app/data/models/mensalidades_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MensalidadesService {
  Future<List<MensalidadeModel>> getMensalidades() async {
    final url = Uri.parse(Utils.endpoint('mensalidades'));

    try {
      final response = await http
          .get(url, headers: await Utils.getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dataResponse = jsonDecode(response.body);

        List<dynamic> rawList = [];

        if (dataResponse is Map<String, dynamic> &&
            dataResponse['data'] is List) {
          rawList = List<dynamic>.from(dataResponse['data']);
        } else if (dataResponse is List) {
          rawList = List<dynamic>.from(dataResponse);
        }

        return rawList.map((item) => MensalidadeModel.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
