import 'package:flutter/material.dart';

// Auth
import '../../presentation/pages/auth/verifica_cadastro_screen.dart';
import '../../presentation/pages/auth/verifica_trabalhador_screen.dart';
import '../../presentation/pages/auth/cadastro_screen.dart';
import '../../presentation/pages/auth/cadastro_trabalhador_screen.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/recuperar_email_screen.dart';
import '../../presentation/pages/auth/recuperar_codigo_screen.dart';
import '../../presentation/pages/auth/recuperar_nova_senha_screen.dart';

// Home e Components
import '../../presentation/pages/home/home_page.dart';

// Outras páginas
import '../../presentation/pages/frequence/frequence_page.dart';
import '../../presentation/pages/debitos/debits_page.dart';
import '../../presentation/pages/debitos/mensalidade_screen.dart';
import '../../presentation/pages/debitos/livraria_screen.dart';
import '../../presentation/pages/perfil/perfil_screen.dart';

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
    AppRoutes.login: (_) => LoginPage(),
    AppRoutes.recuperarEmail: (_) => RecuperarEmailScreen(),
    AppRoutes.recuperarCodigo: (_) => RecuperarCodigoScreen(),
    AppRoutes.recuperarNovaSenha: (_) => RecuperarNovaSenhaScreen(),
    AppRoutes.home: (_) => HomePage(),
    AppRoutes.consultas: (_) => FrequencePage(),
    AppRoutes.debitos: (_) => DebitsPage(),
    AppRoutes.mensalidade: (_) => MensalidadeScreen(),
    AppRoutes.livraria: (_) => LivrariaScreen(),
    AppRoutes.perfil: (_) => PerfilScreen(),
  };
}
