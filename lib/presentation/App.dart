import 'package:celc_app/core/utils/auth_notifier.dart';
import 'package:celc_app/presentation/pages/auth/login_page.dart';
import 'package:celc_app/presentation/pages/perfil/perfil_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home/home_page.dart';
import 'pages/debits/debits_page.dart';
import 'pages/frequence/frequence_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    FrequencePage(),
    DebitsPage(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, auth, child) {
        // Se não estiver autenticado, redireciona para Login
        if (!auth.isAuthenticated) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LoginPage(),
          );
        }

        // Se estiver autenticado, mostra a aplicação principal
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CELC App',
          theme: ThemeData(
            primaryColor: Color(0xFF199DFF),
            scaffoldBackgroundColor: Color(0xFFF9FAFB),
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
          home: Scaffold(
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF199DFF),
              unselectedItemColor: Colors.grey.shade600,
              backgroundColor: Colors.white,
              elevation: 8,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.how_to_reg),
                  label: 'Frequência',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Débitos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
