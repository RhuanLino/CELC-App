class CalendarioItemModel {
  final String id;
  final String data;
  final String descricao;
  final String titulo;

  CalendarioItemModel({
    required this.id,
    required this.data,
    required this.descricao,
    required this.titulo,
  });

  factory CalendarioItemModel.fromJson(Map<String, dynamic> json) {
    return CalendarioItemModel(
      id: json['id'] ?? '',
      data: json['data'] ?? '',
      descricao: json['descricao'] ?? '',
      titulo: json['titulo'] ?? '',
    );
  }
}

class FrequenciaResumoModel {
  final String mes;
  final String ano;
  final int totalAtividades;
  final int totalPresencas;
  final int totalFaltas;
  final double percentualPresenca;

  FrequenciaResumoModel({
    required this.mes,
    required this.ano,
    required this.totalAtividades,
    required this.totalPresencas,
    required this.totalFaltas,
    required this.percentualPresenca,
  });

  factory FrequenciaResumoModel.fromJson(Map<String, dynamic> json) {
    return FrequenciaResumoModel(
      mes: json['mes'] ?? '',
      ano: json['ano'] ?? '',
      totalAtividades: json['totalAtividades'] ?? 0,
      totalPresencas: json['totalPresencas'] ?? 0,
      totalFaltas: json['totalFaltas'] ?? 0,
      percentualPresenca:
          double.tryParse(json['percentualPresenca'].toString()) ?? 0.0,
    );
  }
}
