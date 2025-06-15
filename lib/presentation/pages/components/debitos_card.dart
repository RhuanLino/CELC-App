import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DebitosCard extends StatefulWidget {
  final double? width;
  final double? valorTotal;
  final double? valorMensalidade;
  final double? valorLivraria;
  final double? valorOutros;

  const DebitosCard({
    super.key,
    this.width,
    this.valorTotal,
    this.valorMensalidade,
    this.valorLivraria,
    this.valorOutros,
  });

  @override
  State<DebitosCard> createState() => _DebitosCardState();
}

class _DebitosCardState extends State<DebitosCard> {
  bool _showFirstIcon = true; // Variável de controle do ícone

  @override
  Widget build(BuildContext context) {
    double valorMensalidade = 500;
    double valorLivraria = 80;
    double valorOutros = 100;
    double valorTotal = valorMensalidade + valorLivraria + valorOutros;

    return Container(
      width: widget.width ?? 300,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue[400],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Débitos a Pagar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver todos',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showFirstIcon = !_showFirstIcon;
                          });
                        },
                        icon: Icon(
                          _showFirstIcon ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Total pendente',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'R\$${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(valorTotal)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Linha dividindo
          Divider(height: 1, thickness: 1, color: Colors.blue[200]),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Mensalidade',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text(
                        'R\$${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(valorMensalidade)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Livraria',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text(
                        'R\$${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(valorLivraria)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Outros',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text(
                        'R\$${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(valorOutros)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
