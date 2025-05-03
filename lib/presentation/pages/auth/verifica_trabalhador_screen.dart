import 'package:flutter/material.dart';

class VerificaTrabalhadorScreen extends StatelessWidget {
  const VerificaTrabalhadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Você é trabalhador da casa?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF199DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/cadastro_trab'),
                  child: Text('Sim'),
                ),
                SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                  child: Text('Não'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
