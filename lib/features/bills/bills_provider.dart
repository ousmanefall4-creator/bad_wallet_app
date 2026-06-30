// lib/features/bills/bills_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bad_wallet_app/core/constants.dart';
import 'package:bad_wallet_app/features/dashboard/wallet_provider.dart';

class BillsProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> payBill({
    required String phone,
    required String billType,
    required double amount,
    required String billReference,
    required WalletProvider walletProvider, // Reçoit le provider de solde
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final url = Uri.parse('${AppConstants.baseUrl}/wallets/$phone/bills');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "billType": billType,
          "amount": amount,
          "reference": billReference.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // ACTION : On met à jour le portefeuille suite au paiement
          await walletProvider.fetchWalletData(phone);

          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _errorMessage = "Le paiement a échoué (${response.statusCode})";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Erreur réseau. Connexion impossible.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}