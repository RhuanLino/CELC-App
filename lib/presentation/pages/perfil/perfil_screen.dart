// profile_screen.dart
import 'package:celc_app/presentation/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:celc_app/core/utils/auth_notifier.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(auth),
            const SizedBox(height: 24),
            _buildInfoCards(),
            const SizedBox(height: 24),
            _buildActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthNotifier auth) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
        ),
        const SizedBox(height: 16),
        Text(
          'Orlando Lino',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'orlandolino73@gmail.com',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informações Acadêmicas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Matrícula', '20230001'),
                _buildInfoRow('Curso', 'Ciência da Computação'),
                _buildInfoRow('Período', '5º'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estatísticas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Presenças este mês', '22'),
                _buildInfoRow('Faltas este mês', '3'),
                _buildInfoRow('Débitos pendentes', '2'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configurações'),
          onTap: () {
            // Navegar para tela de configurações
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Ajuda e Suporte'),
          onTap: () {
            // Navegar para tela de ajuda
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Política de Privacidade'),
          onTap: () {
            // Navegar para política de privacidade
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sair da Conta'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              final auth = Provider.of<AuthNotifier>(context, listen: false);
              await auth.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }
}
