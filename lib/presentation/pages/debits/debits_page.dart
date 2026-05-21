import 'package:flutter/material.dart';

import 'package:celc_app/presentation/pages/debits/livraria_tab.dart';
import 'package:celc_app/presentation/pages/debits/mensalidade_tab.dart';

class DebitsPage extends StatefulWidget {
  const DebitsPage({super.key});

  @override
  _DebitsPage createState() => _DebitsPage();
}

// PÁGINA PRINCIPAL QUE ORGANIZA AS ABAS
class _DebitsPage extends State<DebitsPage> {
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
        body: TabBarView(children: [const LivrariaTab(), MensalidadeTab()]),
      ),
    );
  }
}
