import 'package:flutter/material.dart';

class MensalidadeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> mensalidades = [
    {'nome': 'Janeiro', 'valor': 'R\$ 50,00', 'pago': true},
    {'nome': 'Fevereiro', 'valor': 'R\$ 50,00', 'pago': false},
    {'nome': 'Março', 'valor': 'R\$ 50,00', 'pago': false},
  ];

  MensalidadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mensalidades'),
        backgroundColor: Color(0xFF199DFF),
      ),
      body: ListView.builder(
        itemCount: mensalidades.length,
        itemBuilder: (context, index) {
          final m = mensalidades[index];
          return ListTile(
            title: Text(m['nome']),
            subtitle: Text(m['valor']),
            trailing: m['pago']
                ? Icon(Icons.check_circle, color: Colors.green)
                : ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pagamento via PIX ainda não disponível.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF199DFF),
                    ),
                    child: Text('Pagar via PIX'),
                  ),
          );
        },
      ),
    );
  }
}
