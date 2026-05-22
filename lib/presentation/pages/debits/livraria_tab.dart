import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:celc_app/data/models/debits_model.dart';
import 'package:celc_app/data/services/debits_service.dart';

class LivrariaTab extends StatefulWidget {
  const LivrariaTab({super.key});

  @override
  State<LivrariaTab> createState() => _LivrariaTabState();
}

class _LivrariaTabState extends State<LivrariaTab> {
  late Future<List<DebitoItemModel>> futureDebitos;

  double totalDebitosLivraria = 0.0;

  @override
  void initState() {
    super.initState();
    futureDebitos = DebitsService().getDebitosData();

    futureDebitos.then((debitoList) {
      final total = debitoList.fold(0.0, (sum, debito) => sum + debito.total);

      setState(() {
        totalDebitosLivraria = total;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minhas Compras na Livraria',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.payment, size: 16),
                label: const Text('Pagar Débitos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: FutureBuilder<List<DebitoItemModel>>(
            future: futureDebitos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Erro: ${snapshot.error}"));
              }

              final dados = snapshot.data ?? [];

              if (dados.isEmpty) {
                return const Center(child: Text("Nenhum item encontrado."));
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children:
                    dados.map((debito) {
                      return _SecaoItens(
                        data: DateFormat(
                          "d 'de' MMMM 'de' y",
                          'pt_BR',
                        ).format(debito.dataVenda),
                        total: debito.total,
                        status:
                            debito.formaPagamento == 'prazo'
                                ? 'Pendente'
                                : 'Pago',
                        itens:
                            debito.produtos.map((item) {
                              return _Item(
                                nome: item.produto,
                                quantidade: item.quantidade,
                                preco: item.precoUnitario,
                              );
                            }).toList(),
                      );
                    }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

// WIDGET PARA CADA GRUPO DE ITENS DATADO
class _SecaoItens extends StatelessWidget {
  final String data;
  final double total;
  final String status;
  final List<_Item> itens;

  const _SecaoItens({
    required this.data,
    required this.total,
    required this.status,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPaid = status == 'Pago';
    final Color statusColor =
        isPaid ? Colors.green.shade600 : Colors.orange.shade800;

    return Card(
      color: Colors.white,
      shadowColor: Colors.black26,
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (itens.isNotEmpty) const Divider(height: 24),
            ...itens,
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(total)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET PARA CADA ITEM INDIVIDUAL DA LISTA DE COMPRA
class _Item extends StatelessWidget {
  final String nome;
  final int quantidade;
  final double preco;

  const _Item({
    required this.nome,
    required this.quantidade,
    required this.preco,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(fontSize: 16),
                  softWrap: true,
                ),
                const SizedBox(height: 2),
                Text(
                  '$quantidade unidade${quantidade > 1 ? 's' : ''} × ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(preco)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            ).format(quantidade * preco),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
