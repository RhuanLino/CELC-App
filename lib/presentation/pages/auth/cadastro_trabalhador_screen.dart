import 'package:flutter/material.dart';

class CadastroTrabalhadorScreen extends StatelessWidget {
  const CadastroTrabalhadorScreen({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Criar conta',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF199DFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 6),
            Center(child: Text('Preencha os campos para criar sua conta')),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: 'Nome')),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: 'Nome espiritual')),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 10),
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'Senha')),
            SizedBox(height: 10),
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'Confirma senha')),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF199DFF)),
                child: Text('Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
