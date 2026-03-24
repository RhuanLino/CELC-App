import 'package:celc_app/data/services/auth_service.dart';
import 'package:celc_app/presentation/pages/home/home_page.dart';
import 'package:celc_app/core/routes/routes.dart';
import 'package:celc_app/core/providers/homeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  void _login() async {
    String email = _emailController.text;
    String senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    final response = await AuthService().login(email, senha);

    if (response.containsKey('error')) {
      // Se houver erro no login
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['error'])));
    } else {
      context.read<HomeProvider>().setNomeEspiritual(response['nome']);
      // Sucesso no login, redirecionando para a tela principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
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
            Text(
              'Bem-vindo!',
              style: TextStyle(
                fontSize: 40,
                color: Color(0xFF199DFF),
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Image.asset('assets/images/celc_logo.png', width: 200),

            SizedBox(height: 20),
            Text('Insira seus dados', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                floatingLabelStyle: TextStyle(color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
                floatingLabelStyle: TextStyle(color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed:
                    () =>
                        Navigator.pushNamed(context, AppRoutes.recuperarEmail),
                child: Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(color: Color(0xFF199DFF)),
                ),
              ),
            ),
            SizedBox(height: 15),

            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF199DFF),
                minimumSize: Size(300, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Entrar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
