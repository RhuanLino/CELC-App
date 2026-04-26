import 'package:flutter/material.dart';

class DebitosProvider extends ChangeNotifier {

  double totalDebitosLivraria = 0.0;

  void setTotal(double total) {
    totalDebitosLivraria = total;
    notifyListeners(); // avisa todos widgets que mudou
  }

}