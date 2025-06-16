
import 'package:flutter/material.dart';

// Auth
import '../pages/auth/verifica_cadastro_screen.dart';
import '../pages/auth/verifica_trabalhador_screen.dart';
import '../pages/auth/cadastro_screen.dart';
import '../pages/auth/cadastro_trabalhador_screen.dart';
import '../pages/auth/login_screen.dart';
import '../pages/auth/recuperar_email_screen.dart';
import '../pages/auth/recuperar_codigo_screen.dart';
import '../pages/auth/recuperar_nova_senha_screen.dart';

// Home e Components
import '../pages/home/home_screen.dart';

// Outras páginas
import '../pages/consultas/frequencia_screen.dart';
import '../pages/debitos/debitos_screen.dart';
import '../pages/debitos/mensalidade_screen.dart';
import '../pages/debitos/livraria_screen.dart';
import '../pages/perfil/perfil_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String verificaTrabalhador = '/verifica';
  static const String cadastro = '/cadastro';
  static const String cadastroTrabalhador = '/cadastro_trab';
  static const String login = '/login';
  static const String recuperarEmail = '/recuperar_email';
  static const String recuperarCodigo = '/recuperar_codigo';
  static const String recuperarNovaSenha = '/recuperar_nova';
  static const String home = '/home';
  static const String consultas = '/frequencia';
  static const String debitos = '/debitos';
  static const String mensalidade = '/mensalidade';
  static const String livraria = '/livraria';
  static const String perfil = '/perfil';
}

class RouteGenerator {
  static Map<String, Widget Function(BuildContext)> routes = {
    AppRoutes.initial: (_) => VerificaCadastroScreen(),
    AppRoutes.verificaTrabalhador: (_) => VerificaTrabalhadorScreen(),
    AppRoutes.cadastro: (_) => CadastroScreen(),
    AppRoutes.cadastroTrabalhador: (_) => CadastroTrabalhadorScreen(),
    AppRoutes.login: (_) => LoginScreen(),
    AppRoutes.recuperarEmail: (_) => RecuperarEmailScreen(),
    AppRoutes.recuperarCodigo: (_) => RecuperarCodigoScreen(),
    AppRoutes.recuperarNovaSenha: (_) => RecuperarNovaSenhaScreen(),
    AppRoutes.home: (_) => HomeScreen(),
    AppRoutes.consultas: (_) => FrequenciaScreen(),
    AppRoutes.debitos: (_) => DebitosScreen(),
    AppRoutes.mensalidade: (_) => MensalidadeScreen(),
    AppRoutes.livraria: (_) => LivrariaScreen(),
    AppRoutes.perfil: (_) => PerfilScreen(),
  };
}