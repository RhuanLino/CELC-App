import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Map<String, dynamic>> items = [
    {
      'color': Colors.white,
      'title': 'Oferta Especial',
      'subtitle': 'Descontos de até 50%',
    },
    {
      'color': Colors.white,
      'title': 'Novidades',
      'subtitle': 'Confira nossos lançamentos',
    },
    {
      'color': Colors.white,
      'title': 'Destaque',
      'subtitle': 'Produtos em alta',
    },
    {
      'color': Colors.white,
      'title': 'Loja',
      'subtitle': 'Promoção alta',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Olá, ',
            style: TextStyle(color: Colors.white, fontSize: 20),
            children: [
              TextSpan(
                text: 'Usuário!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: Color(0xFF199DFF),
        actions: [Icon(Icons.notifications, color: Colors.white)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth * 0.4; // 40% da largura
                  final margin = 8.0; // Espaçamento entre itens

                  return CarouselSlider(
                    options: CarouselOptions(
                      initialPage: 0,
                      height: 180.0,
                      autoPlay: false,
                      viewportFraction: (itemWidth + margin) / constraints.maxWidth,
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
                              color: item['color'],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    item['subtitle'],
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.9),
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  );
                } 
              ),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage('assets/cesta.jpg'), // ou NetworkImage
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Colabore com a cesta básica',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: Text('Saiba mais'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Image.asset('assets/graficos.png'), // gráfico fake temporário
            ],
          ),
        ),
      ),
    );
  }
}
