import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  void _login() {
    String email = _emailController.text;
    String senha = _senhaController.text;

    if (email == 'teste@email.com' && senha == '123456') {
      Navigator.pushReplacementNamed(context, '/nav'); // Redireciona para as telas com menu
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail ou senha inválidos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 100, color: Color(0xFF199DFF)),
            Text(
              'Bem-vindo!',
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF199DFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Insira seus dados'),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/recuperar_email'),
                child: Text('Esqueceu sua senha?'),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF199DFF),
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
