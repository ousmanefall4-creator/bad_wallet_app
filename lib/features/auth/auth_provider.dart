// lib/features/auth/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _phoneNumber;

  bool get isLoading => _isLoading;
  String? get phoneNumber => _phoneNumber;

  Future<bool> login(String phone) async {
    if (phone.trim().isEmpty || phone.length < 8) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${AppConstants.baseUrl}/auth/login');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"phone": phone.trim()}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          await _storage.write(key: 'user_phone', value: phone.trim());
          _phoneNumber = phone.trim();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkLoginStatus() async {
    _phoneNumber = await _storage.read(key: 'user_phone');
    return _phoneNumber != null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'user_phone');
    _phoneNumber = null;
    notifyListeners();
  }
}