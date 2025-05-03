import 'package:flutter/material.dart';

class RecuperarEmailScreen extends StatelessWidget {
  const RecuperarEmailScreen({super.key});

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
            Text('Recuperar senha', style: TextStyle(fontSize: 24, color: Color(0xFF199DFF), fontWeight: FontWeight.bold)),
            Text('Um código de verificação será enviado para o email'),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(hintText: 'exemplo@email.com')),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () => Navigator.pushNamed(context, '/recuperar_codigo'),
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
