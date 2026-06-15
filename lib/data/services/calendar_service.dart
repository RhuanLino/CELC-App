import 'dart:convert';
import 'package:celc_app/core/utils/utils.dart';
import 'package:celc_app/data/models/calendar_model.dart';
import 'package:http/http.dart' as http;

class CalendarService {
  Future<List<CalendarioItemModel>> getCalendario() async {
    final url = Uri.parse(Utils.endpoint('calendario'));

    try {
      final response = await http
          .get(url, headers: await Utils.getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dataResponse = jsonDecode(response.body);
        final List<dynamic> rawList = dataResponse['data'] ?? [];
        return rawList
            .map((item) => CalendarioItemModel.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<FrequenciaResumoModel?> getFrequenciaResumo({
    required int mes,
    required int ano,
  }) async {
    final url = Uri.parse(
      Utils.endpoint('frequenciaResumo') + '?mes=$mes&ano=$ano',
    );

    try {
      final response = await http
          .get(url, headers: await Utils.getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dataResponse = jsonDecode(response.body);
        return FrequenciaResumoModel.fromJson(dataResponse);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
