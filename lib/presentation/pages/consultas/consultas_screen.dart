import 'package:flutter/material.dart';

class ConsultasScreen extends StatelessWidget {
  final List<Map<String, String>> consultas = [
    {'data': '23 Março'},
    {'data': '30 Março'},
    {'data': '06 Abril'},
  ];

  ConsultasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Olá, ',
            style: TextStyle(color: Colors.white, fontSize: 20),
            children: [
              TextSpan(
                text: 'Usuário!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: Color(0xFF199DFF),
        actions: [
          Icon(Icons.notifications, color: Colors.white),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage('assets/cesta.jpg'), // ajuste conforme necessário
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF199DFF),
                      ),
                      child: Text('Saiba mais'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Consultas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                ...consultas.map(
                  (consulta) => Chip(
                    label: Text(consulta['data']!),
                    backgroundColor: Color(0xFF199DFF),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
                ActionChip(
                  avatar: Icon(Icons.add, color: Colors.white),
                  backgroundColor: Color(0xFF199DFF),
                  label: Text(''),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Adicionar nova consulta')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
