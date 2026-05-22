import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:celc_app/data/services/debits_service.dart';
import 'package:celc_app/presentation/pages/debits/livraria_tab.dart';
import 'package:celc_app/presentation/pages/debits/mensalidade_tab.dart';

class DebitsPage extends StatefulWidget {
  const DebitsPage({super.key});

  @override
  State<DebitsPage> createState() => _DebitsPage();
}

// PÁGINA PRINCIPAL QUE ORGANIZA AS ABAS
class _DebitsPage extends State<DebitsPage> {
  double totalDebitosLivraria = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTotalDebitos();
  }

  Future<void> _loadTotalDebitos() async {
    try {
      final debitoList = await DebitsService().getDebitosData();
      final total = debitoList.fold(0.0, (sum, debito) => sum + debito.total);
      if (mounted) {
        setState(() {
          totalDebitosLivraria = total;
        });
      }
    } catch (e) {
      // ignore
    }
  }

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
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.blue,
                  ),
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
                  children: [
                    Icon(Icons.book_outlined),
                    SizedBox(width: 8),
                    Text("Livraria"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_outlined),
                    SizedBox(width: 8),
                    Text("Mensalidade"),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            _ResumoDebitos(totalDebitosLivraria: totalDebitosLivraria),
            Expanded(
              child: TabBarView(
                children: [const LivrariaTab(), MensalidadeTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoDebitos extends StatelessWidget {
  final double totalDebitosLivraria;

  const _ResumoDebitos({required this.totalDebitosLivraria});

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
            valor: NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            ).format(totalDebitosLivraria),
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 12),
          _CardResumo(
            icon: Icons.check_circle_outline,
            label: 'Mensalidades Pagas',
            valor: '0',
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 12),
          _CardResumo(
            icon: Icons.error_outline,
            label: 'Mensalidades Pendentes',
            valor: '0',
            color: Colors.orange.shade800,
          ),
        ],
      ),
    );
  }
}

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
          border: Border.all(color: color.withValues(alpha: 0.7)),
          color: color.withValues(alpha: 0.05),
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
