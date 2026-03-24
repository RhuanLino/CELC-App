class TotaisDebitosModel {
  final bool success;
  final double totalLivraria;

  TotaisDebitosModel({required this.success, required this.totalLivraria});

  factory TotaisDebitosModel.fromJson(Map<String, dynamic> json) {
    return TotaisDebitosModel(
      success: json['success'],
      totalLivraria: json['totalLivraria'],
    );
  }
}
