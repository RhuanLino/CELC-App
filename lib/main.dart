import 'package:celc_app/core/utils/auth_notifier.dart';
import 'package:celc_app/core/providers/debitosProvider.dart';
import 'package:flutter/material.dart';
import 'package:celc_app/presentation/App.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cria uma instância do AuthNotifier que carregará o token automaticamente
  final authNotifier = AuthNotifier();

  await authNotifier.init(); // Inicializa o AuthNotifier para carregar o token

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => authNotifier),
        ChangeNotifierProvider(create: (_) => DebitosProvider()),
      ],
      child: const App(),
    ),
  );
}
