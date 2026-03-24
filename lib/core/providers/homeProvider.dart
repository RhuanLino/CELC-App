import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {

  String nomeEspiritual = "Irmão";

  void setNomeEspiritual(String nome) {
    nomeEspiritual = nome;
    notifyListeners(); // avisa todos widgets que mudou
  }
}