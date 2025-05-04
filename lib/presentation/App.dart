import 'package:flutter/material.dart';
import 'pages/home/home_screen.dart';
import 'pages/debitos/debitos_screen.dart';
import 'pages/consultas/consultas_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ConsultasScreen(),
    DebitosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.how_to_reg), label: 'Frequência'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Débitos'),
        ],
      ),
    );
  }
}