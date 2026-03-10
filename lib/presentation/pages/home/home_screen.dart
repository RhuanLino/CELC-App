import 'package:carousel_slider/carousel_slider.dart';
import 'package:celc_app/presentation/pages/components/debitos_card.dart';
import 'package:celc_app/presentation/pages/components/frequencia_progress.dart';
import 'package:celc_app/presentation/pages/consultas/frequencia_screen.dart';
import 'package:celc_app/core/constants/debitos_constants.dart';
import 'package:celc_app/presentation/pages/perfil/perfil_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  Color _getLightColor(Color baseColor) {
    return baseColor.withOpacity(0.06);
  }

  Color _getDarkColor(Color baseColor) {
    return HSLColor.fromColor(baseColor)
        .withLightness(0.6) // Ajuste este valor para mudar a escuridão
        .toColor();
  }

  final List<Map<String, dynamic>> items = [
    {
      'color': Colors.blue,
      'icon': Icons.pedal_bike,
      'title': 'Oferta Especial',
      'subtitle': 'Descontos de até 50%',
      'data': '10/23/2025',
    },
    {
      'color': Colors.deepPurple,
      'icon': Icons.home,
      'title': 'Novidades',
      'subtitle': 'Confira nossos lançamentos',
      'data': '01/12/2025',
    },
    {
      'color': const Color.fromARGB(255, 206, 28, 28),
      'icon': Icons.kayaking,
      'title': 'Destaque',
      'subtitle': 'Produtos em alta',
      'data': '10/01/2025',
    },
    {
      'color': Colors.orange,
      'icon': Icons.baby_changing_station,
      'title': 'Loja',
      'subtitle': 'Promoção alta',
      'data': '04/05/2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Olá, ',
            style: TextStyle(color: Colors.black87, fontSize: 20),
            children: [
              TextSpan(
                text: 'Usuário!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.only(right: 15),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Abrir notificações',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilScreen()));
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
                  final itemWidth =
                      constraints.maxWidth * 0.5; // 40% da largura
                  final margin = 8.0; // Espaçamento entre itens

                  return CarouselSlider(
                    options: CarouselOptions(
                      initialPage: 0,
                      height: 150.0,
                      autoPlay: false,
                      viewportFraction:
                          (itemWidth + margin) / constraints.maxWidth,
                      enableInfiniteScroll: false,
                      padEnds: false,
                      autoPlayInterval: Duration(seconds: 6),
                    ),
                    items:
                        items.map((item) {
                          return Container(
                            width: itemWidth, // Largura fixa
                            margin: EdgeInsets.only(right: margin),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: Offset(0, 0.5),
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    margin: EdgeInsets.only(bottom: 8.0),
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
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    item['subtitle'],
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.9),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
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
                margin: EdgeInsets.only(top: 15),
                child: FrequenciaProgress(
                  percentage: 0,
                  percentageAbsent: 0,
                  presentDays: 0,
                  absentDays: 0,
                  // Optional parameters:
                  width: 500, // custom width
                  primaryColor: Colors.green, // custom primary color
                  absentColor: Colors.red, // custom absent color
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: DebitosCard(width: 500, valorLivraria: DebitosConstants.totalDebitosLivraria,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
