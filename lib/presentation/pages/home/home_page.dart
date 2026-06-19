import 'package:carousel_slider/carousel_slider.dart';
import 'package:celc_app/data/models/calendar_model.dart';
import 'package:celc_app/data/models/debits_model.dart';
import 'package:celc_app/data/services/calendar_service.dart';
import 'package:celc_app/data/services/debits_service.dart';
import 'package:celc_app/presentation/widgets/debitos_card.dart';
import 'package:celc_app/presentation/widgets/frequencia_progress.dart';
import 'package:celc_app/presentation/pages/perfil/perfil_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  late Future<String?> futureNomeEspiritual;
  late Future<Map<String, dynamic>> futureDebits;

  double totalDebitsLivraria = 0.0;
  double totalDebitsMensalidade = 0.0;
  double totalDebitsOutros = 0.0;

  FrequenciaResumoModel? _resumo;

  @override
  void initState() {
    super.initState();
    futureNomeEspiritual = storage.read(key: 'nomeEspiritual');
    futureDebits = DebitsService().getTotaisDebits();

    futureDebits.then((json) {
      final debito = TotaisDebitsModel.fromJson(json);
      setState(() {
        totalDebitsLivraria = debito.totalLivraria;
        totalDebitsMensalidade = debito.totalMensalidade;
        totalDebitsOutros = debito.totalOutros;
      });
    });

    _loadFrequencia();
  }

  Future<void> _loadFrequencia() async {
    final now = DateTime.now();
    final resumo = await CalendarService().getFrequenciaResumo(
      mes: now.month,
      ano: now.year,
    );
    if (mounted) {
      setState(() => _resumo = resumo);
    }
  }

  Color _getLightColor(Color baseColor) => baseColor.withOpacity(0.06);

  Color _getDarkColor(Color baseColor) =>
      HSLColor.fromColor(baseColor).withLightness(0.6).toColor();

  final List<Map<String, dynamic>> items = [
    {
      'color': Colors.blue,
      'icon': Icons.card_giftcard,
      'title': 'App Celc!',
      'subtitle': 'Aproveite!',
      'data': 'Hoje',
    },
    {
      'color': Colors.amber,
      'icon': Icons.add_alert_rounded,
      'title': 'Anúncios',
      'subtitle': 'Fique atento aos anúncios',
      'data': 'Hoje',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Converte 0.0–1.0 para 0–100 para o widget FrequenciaProgress
    final presencaPct = ((_resumo?.percentualPresenca ?? 0.0) * 100).round();
    final totalAtividades = _resumo?.totalAtividades ?? 0;
    final totalPresencas = _resumo?.totalPresencas ?? 0;
    final totalFaltas = _resumo?.totalFaltas ?? 0;
    final ausentePct =
        totalAtividades > 0
            ? ((totalFaltas / totalAtividades) * 100).round()
            : 0;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: futureNomeEspiritual,
          builder: (context, snapshot) {
            final nome = snapshot.data ?? '';
            return RichText(
              text: TextSpan(
                text: 'Olá, ',
                style: const TextStyle(color: Colors.black87, fontSize: 20),
                children: [
                  TextSpan(
                    text: '$nome!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
        actionsPadding: const EdgeInsets.only(right: 15),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Abrir notificações',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PerfilScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth * 0.5;
                  const margin = 8.0;

                  return CarouselSlider(
                    options: CarouselOptions(
                      initialPage: 0,
                      height: 150.0,
                      autoPlay: false,
                      viewportFraction:
                          (itemWidth + margin) / constraints.maxWidth,
                      enableInfiniteScroll: false,
                      padEnds: false,
                      autoPlayInterval: const Duration(seconds: 6),
                    ),
                    items:
                        items.map((item) {
                          return Container(
                            width: itemWidth,
                            margin: const EdgeInsets.only(right: margin),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, 0.5),
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    decoration: BoxDecoration(
                                      color: _getLightColor(item['color']),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Icon(
                                      item['icon'],
                                      color: item['color'],
                                      size: 20.0,
                                    ),
                                  ),
                                  Text(
                                    item['title'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    item['subtitle'],
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.9),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    item['data'],
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.5),
                                      fontSize: 10.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                child: FrequenciaProgress(
                  percentage: presencaPct,
                  percentageAbsent: ausentePct,
                  presentDays: totalPresencas,
                  absentDays: totalFaltas,
                  width: 500,
                  primaryColor: Colors.green,
                  absentColor: Colors.red,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                child: DebitosCard(
                  width: 500,
                  valorLivraria: totalDebitsLivraria,
                  valorMensalidade: totalDebitsMensalidade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
