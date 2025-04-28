import 'package:flutter/material.dart';

class LivrariaScreen extends StatelessWidget {
  final List<Map<String, String>> produtos = [
    {'nome': 'Livro de Doutrina', 'valor': 'R\$ 40,00'},
    {'nome': 'Agenda Espiritual', 'valor': 'R\$ 25,00'},
    {'nome': 'Caneca personalizada', 'valor': 'R\$ 15,00'},
  ];

  LivrariaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livraria'),
        backgroundColor: Color(0xFF199DFF),
      ),
      body: ListView.separated(
        itemCount: produtos.length,
        separatorBuilder: (context, _) => Divider(),
        itemBuilder: (context, index) {
          final p = produtos[index];
          return ListTile(
            title: Text(p['nome']!),
            subtitle: Text(p['valor']!),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pagamento via PIX ainda não disponível.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF199DFF),
              ),
              child: Text('PIX'),
            ),
          );
        },
      ),
    );
  }
}
