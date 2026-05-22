// profile_screen.dart
import 'package:celc_app/data/models/debits_model.dart';
import 'package:celc_app/presentation/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:celc_app/core/utils/auth_notifier.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  late Future<String?> futureNomeEspiritual;

  @override
  void initState() {
    super.initState();
    futureNomeEspiritual = storage.read(key: 'nomeEspiritual');
  }

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
        FutureBuilder<String?>(
          future: futureNomeEspiritual,
          builder: (context, snapshot) {
            final nome = snapshot.data ?? '';
            return Text(
              '$nome',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            );
          },
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
          color: Colors.white,
          shadowColor: Colors.black26,
          elevation: 0.5,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informações Ministeriais',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Nome Social', 'Orlando da Silva Lino'),
                _buildInfoRow('Grau', '5º'),
                _buildInfoRow('Posição', 'Sacerdote'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
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
          leading: const Icon(Icons.message),
          title: const Text('Contato'),
          onTap: () async {
            final Uri url = Uri.parse('https://wa.me/5561984785501');
            try {
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível abrir o WhatsApp.'),
                    ),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao abrir o WhatsApp.')),
                );
              }
            }
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
