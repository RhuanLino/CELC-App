import 'package:flutter/material.dart';

class RecuperarNovaSenhaScreen extends StatelessWidget {
  const RecuperarNovaSenhaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Recuperar senha',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF199DFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Digite sua nova senha'),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(hintText: 'Nova senha')),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(hintText: 'Confirmar senha')),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Senha atualizada com sucesso!')),
                );
              },
              child: Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
