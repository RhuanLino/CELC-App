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
  double totalDebitosMensalidade = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTotalDebitos();
  }

  Future<void> _loadTotalDebitos() async {
    try {
      final data = await DebitsService().getTotaisDebits();

      if (!mounted) return;

      setState(() {
        totalDebitosLivraria = (data['totalLivraria'] ?? 0).toDouble();

        totalDebitosMensalidade = (data['totalMensalidade'] ?? 0).toDouble();
      });
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
            _ResumoDebitos(
              totalDebitosLivraria: totalDebitosLivraria,
              totalDebitosMensalidade: totalDebitosMensalidade,
            ),
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
  final double totalDebitosMensalidade;

  const _ResumoDebitos({
    required this.totalDebitosLivraria,
    required this.totalDebitosMensalidade,
  });

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
            icon: Icons.calendar_month,
            label: 'Débitos Mensalidade',
            valor: NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            ).format(totalDebitosMensalidade),
            color: Colors.green.shade600,
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
  final String? warningText;
  final IconData? warningIcon;

  const _CardResumo({
    super.key,
    required this.icon,
    required this.label,
    required this.valor,
    required this.color,
    this.warningText,
    this.warningIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Calcula uma cor legível sobre o fundo (onColor)
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    final onColorSubtle = onColor.withOpacity(0.75);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ícone principal + label
          Row(
            children: [
              Icon(icon, color: onColorSubtle, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: onColorSubtle, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),

          // Valor em destaque
          Text(
            valor,
            style: TextStyle(
              color: onColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          // Aviso opcional no rodapé (ex: "2 mensalidades atrasadas")
          if (warningText != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  warningIcon ?? Icons.info_outline,
                  color: onColorSubtle,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    warningText!,
                    style: TextStyle(color: onColorSubtle, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
