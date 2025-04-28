import 'package:flutter/material.dart';

import 'verifica_cadastro_screen.dart';
import 'verifica_trabalhador_screen.dart';
import 'cadastro_screen.dart';
import 'cadastro_trabalhador_screen.dart';
import 'login_screen.dart';
import 'recuperar_email_screen.dart';
import 'recuperar_codigo_screen.dart';
import 'recuperar_nova_senha_screen.dart';
import 'home_screen.dart';
import 'consultas_screen.dart';
import 'debitos_screen.dart';
import 'mensalidade_screen.dart';
import 'livraria_screen.dart';
import 'bottom_nav.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Flutter',
      theme: ThemeData(
        primaryColor: Color(0xFF199DFF),
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF199DFF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF199DFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF199DFF), width: 2),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => VerificaCadastroScreen(),
        '/verifica': (_) => VerificaTrabalhadorScreen(),
        '/cadastro': (_) => CadastroScreen(),
        '/cadastro_trab': (_) => CadastroTrabalhadorScreen(),
        '/login': (_) => LoginScreen(),
        '/recuperar_email': (_) => RecuperarEmailScreen(),
        '/recuperar_codigo': (_) => RecuperarCodigoScreen(),
        '/recuperar_nova': (_) => RecuperarNovaSenhaScreen(),
        '/nav': (_) => BottomNavController(), // redirecionamento após login
        '/home': (_) => HomeScreen(),
        '/consultas': (_) => ConsultasScreen(),
        '/debitos': (_) => DebitosScreen(),
        '/mensalidade': (_) => MensalidadeScreen(),
        '/livraria': (_) => LivrariaScreen(),
      },
    );
  }
}
