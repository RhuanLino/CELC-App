class MensalidadeModel {
  final String nome;
  final String valor;
  final String status;
  final String? vencimento;
  final String? pagoEm;

  MensalidadeModel({
    required this.nome,
    required this.valor,
    required this.status,
    this.vencimento,
    this.pagoEm,
  });

  factory MensalidadeModel.fromJson(Map<String, dynamic> json) {
    return MensalidadeModel(
      nome: json['nome'] ?? '',
      valor: json['valor'] ?? '',
      status: json['status'] ?? '',
      vencimento: json['vencimento'],
      pagoEm: json['pago_em'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'valor': valor,
      'status': status,
      'vencimento': vencimento,
      'pago_em': pagoEm,
    };
  }
}
