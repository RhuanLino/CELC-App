import 'package:flutter/material.dart';

class VerificaCadastroScreen extends StatelessWidget {
  const VerificaCadastroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Você já possui cadastro?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF199DFF),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Sim'),
              ),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/verifica'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Não'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
