import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthNotifier extends ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _token;

  AuthNotifier() {
    init();
  }

  Future<void> init() async {
    _token = await _storage.read(key: 'token');
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  bool get isAuthenticated => _token != null;
}