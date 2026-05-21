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

class DebitoItemModel {
  final String vendaId;
  final String obreiroId;
  final DateTime dataVenda;
  final String formaPagamento;
  final String? observacao;
  final double total;
  final List<ProdutoDebitoModel> produtos;

  DebitoItemModel({
    required this.vendaId,
    required this.obreiroId,
    required this.dataVenda,
    required this.formaPagamento,
    this.observacao,
    required this.total,
    required this.produtos,
  });

  factory DebitoItemModel.fromJson(Map<String, dynamic> json) {
    return DebitoItemModel(
      vendaId: json['venda_id'],
      obreiroId: json['obreiro_id'],
      dataVenda: DateTime.parse(json['data_venda']),
      formaPagamento: json['forma_pagamento'],
      observacao: json['observacao'],
      total: (json['total'] as num).toDouble(),
      produtos:
          (json['produtos'] as List)
              .map((p) => ProdutoDebitoModel.fromJson(p))
              .toList(),
    );
  }
}

class ProdutoDebitoModel {
  final String produto;
  final double precoUnitario;
  final int quantidade;
  final double subtotal;

  ProdutoDebitoModel({
    required this.produto,
    required this.precoUnitario,
    required this.quantidade,
    required this.subtotal,
  });

  factory ProdutoDebitoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoDebitoModel(
      produto: json['produto'],
      precoUnitario: (json['preco_unitario'] as num).toDouble(),
      quantidade: json['quantidade'],
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}
