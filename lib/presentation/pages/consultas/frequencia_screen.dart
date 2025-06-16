import 'package:celc_app/presentation/pages/components/grafico_barras.dart';
import 'package:flutter/material.dart';

// --- Widget da Tela de Detalhes da Frequência ---
class FrequenciaScreen extends StatelessWidget {
  final Map<String, Map<String, int>> monthlyAttendance = {
    'Semana 1': {'presence': 8, 'absence': 2},
    'Semana 2': {'presence': 7, 'absence': 3},
    'Semana 3': {'presence': 9, 'absence': 1},
    'Semana 4': {'presence': 6, 'absence': 4},
  };

  FrequenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Frequência'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSeletorMes(),
              const SizedBox(height: 16),

              SizedBox(
                height: 300,
                child: AttendanceChart(monthlyData: monthlyAttendance),
              ),
              const SizedBox(height: 12),
              _buildCardMateria(
                materia: 'Semana 1',
                faltas: 1,
                aulasTotais: 20,
                cor: Colors.orange,
              ),
              _buildCardMateria(
                materia: 'Semana 2',
                faltas: 0,
                aulasTotais: 22,
                cor: Colors.blue,
              ),
              _buildCardMateria(
                materia: 'Semana 3',
                faltas: 2,
                aulasTotais: 18,
                cor: Colors.green,
              ),
              _buildCardMateria(
                materia: 'Semana 4',
                faltas: 1,
                aulasTotais: 19,
                cor: Colors.yellow,
              ),
              const SizedBox(height: 24),
              const Text(
                'Histórico de Faltas (Junho)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildRegistroFalta(data: '03/06/2025', materia: 'Semana 1'),
              _buildRegistroFalta(data: '05/06/2025', materia: 'Semana 2'),
              _buildRegistroFalta(data: '10/06/2025', materia: 'Semana 3'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeletorMes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
        const Text(
          'Junho 2025',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
      ],
    );
  }

  Widget _buildCardMateria({
    required String materia,
    required int faltas,
    required int aulasTotais,
    required Color cor,
  }) {
    final presencas = aulasTotais - faltas;
    final percentual = presencas / aulasTotais;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              materia,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentual,
              backgroundColor: cor.withOpacity(0.2),
              color: cor,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(percentual * 100).toStringAsFixed(0)}% de presença',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '$faltas falta${faltas != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistroFalta({required String data, required String materia}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: const Icon(Icons.event_busy, color: Colors.red),
        title: Text('Falta em $materia'),
        trailing: Text(data, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
