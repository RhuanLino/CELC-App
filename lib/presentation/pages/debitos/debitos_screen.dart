import 'package:flutter/material.dart';

// PÁGINA PRINCIPAL QUE ORGANIZA AS ABAS
class DebitosScreen extends StatelessWidget {
  const DebitosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Cor de fundo mais suave
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 1,
          title: const Text(
            'Meus Débitos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            // WIDGET DE DATA NO TOPO
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'quarta-feira, 11 de junho de 2025',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.blue.shade700,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.book_outlined), SizedBox(width: 8), Text("Livraria")],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.calendar_month_outlined), SizedBox(width: 8), Text("Mensalidade")],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // CONTEÚDO DA ABA LIVRARIA
            AbaLivraria(),
            // CONTEÚDO DA ABA MENSALIDADE (A FAZER)
            Center(child: Text("Nenhum débito encontrado")),
          ],
        ),
      ),
    );
  }
}

// WIDGET PARA O CONTEÚDO DA ABA LIVRARIA
class AbaLivraria extends StatelessWidget {
  const AbaLivraria({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SEÇÃO SUPERIOR COM OS CARDS DE RESUMO
        _ResumoDebitos(),
        // ÁREA DO TÍTULO E BOTÃO "PAGAR DÉBITOS"
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meus Itens da Livraria',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Ação para o botão de pagar débitos
                },
                icon: const Icon(Icons.payment, size: 16),
                label: const Text('Pagar Débitos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              )
            ],
          ),
        ),
        // LISTA DE ITENS AGRUPADOS POR DATA
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _SecaoItens(
                data: '14 de junho de 2023',
                total: 89.70,
                status: 'Pendente',
                itens: [
                  _Item(nome: 'Dom Casmurro', quantidade: 1, preco: 39.90),
                  _Item(nome: 'Caderno Universitário', quantidade: 2, preco: 24.90),
                ],
              ),
              _SecaoItens(
                data: '09 de junho de 2023',
                total: 22.00,
                status: 'Pago',
                itens: [
                  _Item(nome: 'Caneta Esferográfica', quantidade: 5, preco: 3.50),
                  _Item(nome: 'Lápis', quantidade: 3, preco: 1.50),
                ],
              ),
              _SecaoItens(
                data: '04 de junho de 2023',
                total: 34.90,
                status: 'Pendente',
                // Simulando uma seção sem itens visíveis como na imagem
                itens: [],
              ),
              const SizedBox(height: 16),
              // TEXTO FINAL COM O TOTAL A PAGAR
              Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.normal,
                        ),
                    children: const <TextSpan>[
                      TextSpan(text: 'Total a pagar '),
                      TextSpan(
                        text: 'R\$ 124,60',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

// WIDGET QUE CONTÉM A LINHA DE CARDS DE RESUMO
class _ResumoDebitos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          _CardResumo(
            icon: Icons.receipt_long_outlined,
            label: 'Débitos Livraria',
            valor: 'R\$ 124,60',
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 12),
          _CardResumo(
            icon: Icons.check_circle_outline,
            label: 'Mensalidades Pagas',
            valor: '2',
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 12),
          _CardResumo(
            icon: Icons.error_outline,
            label: 'Mensalidades Pendentes',
            valor: '3',
            color: Colors.orange.shade800,
          ),
        ],
      ),
    );
  }
}

// WIDGET PARA CADA CARD DE RESUMO INDIVIDUAL (CORRIGIDO)
class _CardResumo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color color;

  const _CardResumo({
    required this.icon,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.7)),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET PARA CADA GRUPO DE ITENS DATADO
class _SecaoItens extends StatelessWidget {
  final String data;
  final double total;
  final String status;
  final List<_Item> itens;

  const _SecaoItens({required this.data, required this.total, required this.status, required this.itens});

  @override
  Widget build(BuildContext context) {
    final bool isPaid = status == 'Pago';
    final Color statusColor = isPaid ? Colors.green.shade600 : Colors.orange.shade800;

    return Card(
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
            Text(data, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (itens.isNotEmpty) const Divider(height: 24),
            ...itens,
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: R\$ ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
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

  const _Item({required this.nome, required this.quantidade, required this.preco});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nome, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                '$quantidade unidade${quantidade > 1 ? 's' : ''} × R\$ ${preco.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          Text(
            'R\$ ${(quantidade * preco).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
