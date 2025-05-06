import 'package:celc_app/core/utils/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:celc_app/presentation/App.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cria uma instância do AuthNotifier que carregará o token automaticamente
  final authNotifier = AuthNotifier();

  await authNotifier.init(); // Inicializa o AuthNotifier para carregar o token

  runApp(
    ChangeNotifierProvider(
      create: (context) => authNotifier,
      child: const App(),
    ),
  );
}
