// lib/features/transfers/transfer_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bad_wallet_app/core/constants.dart';
import 'package:bad_wallet_app/features/dashboard/wallet_provider.dart';

class TransferProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> makeTransfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
    required WalletProvider walletProvider, // Reçoit le provider de solde
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final url = Uri.parse('${AppConstants.baseUrl}/wallets/$senderPhone/transfers');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "recipient": receiverPhone.trim(),
          "amount": amount,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // ACTION : On force le rafraîchissement immédiat du solde global !
          await walletProvider.fetchWalletData(senderPhone);
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _errorMessage = "Le transfert a échoué (${response.statusCode})";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Erreur réseau. Connexion impossible au serveur.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}