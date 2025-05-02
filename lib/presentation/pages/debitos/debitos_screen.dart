import 'package:flutter/material.dart';

class DebitosScreen extends StatelessWidget {
  final List<Map<String, String>> debitos = [
    {'nome': 'Janeiro', 'valor': 'R\$ 50,00'},
    {'nome': 'Fevereiro', 'valor': 'R\$ 50,00'},
    {'nome': 'Março', 'valor': 'R\$ 50,00'},
  ];

  DebitosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Débitos'),
        backgroundColor: Color(0xFF199DFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: debitos.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (context, index) {
            final item = debitos[index];
            return ListTile(
              title: Text(item['nome']!),
              subtitle: Text(item['valor']!),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pagamento via PIX em breve.')),
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
      ),
    );
  }
}
