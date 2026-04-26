class TotaisDebitsModel {
  final bool success;
  final double totalLivraria;
  final double totalMensalidade;
  final double totalOutros;

  TotaisDebitsModel({
    required this.success,
    required this.totalLivraria,
    required this.totalMensalidade,
    required this.totalOutros,
  });

  factory TotaisDebitsModel.fromJson(Map<String, dynamic> json) {
    return TotaisDebitsModel(
      success: json['success'],
      totalLivraria: json['totalLivraria'],
      totalMensalidade: json['totalMensalidade'],
      totalOutros: json['totalOutros'],
    );
  }
}
