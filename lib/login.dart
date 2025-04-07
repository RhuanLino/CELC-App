import 'package:flutter/material.dart';

void main() => runApp(Login());

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Moderno',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF199DFF),
        scaffoldBackgroundColor: Color(0xFFF2F2F7),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String senha = '';

  void _login() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login realizado com sucesso!')),
      );
    }
  }

  void _recuperarSenha() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link de recuperação enviado!')),
    );
  }

  void _cadastrar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Indo para tela de cadastro...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
               Icon(Icons.menu_book,size: 80, color: Color(0xFF199DFF)),
                SizedBox(height: 16),
                Text(
                  'Bem-vindo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF199DFF),
                  ),
                ),
                SizedBox(height: 32),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: Color(0xFF199DFF)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => email = value,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Digite um e-mail válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Color(0xFF199DFF)),
                  ),
                  obscureText: true,
                  onChanged: (value) => senha = value,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Senha precisa de pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _recuperarSenha,
                    child: Text(
                      'Esqueci minha senha',
                      style: TextStyle(color: Color(0xFF199DFF)),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF199DFF),
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Entrar'),
                ),
                SizedBox(height: 20),
                Divider(height: 1, color: Colors.grey[300]),
                SizedBox(height: 20),
                Text("Ainda não tem uma conta?"),
                TextButton(
                  onPressed: _cadastrar,
                  child: Text(
                    'Criar conta',
                    style: TextStyle(color: Color(0xFF199DFF)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
