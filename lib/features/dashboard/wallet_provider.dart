// lib/features/dashboard/wallet_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bad_wallet_app/core/constants.dart';
import 'package:bad_wallet_app/models/transaction_model.dart';

// Les 3 états imposés par le sujet d'examen
enum WalletStatus { loading, loaded, error }

class WalletProvider with ChangeNotifier {
  WalletStatus _status = WalletStatus.loading;
  double _balance = 0.0;
  List<TransactionModel> _recentTransactions = [];
  String _errorMessage = '';

  // Getters
  WalletStatus get status => _status;
  double get balance => _balance;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  String get errorMessage => _errorMessage;

  // Récupérer les données du portefeuille (Solde + Transactions)
  Future<void> fetchWalletData(String phone) async {
    _status = WalletStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // 1. Récupération du Solde : GET /api/wallets/{phone}/balance
      final balanceResponse = await http.get(
        Uri.parse('${AppConstants.baseUrl}/wallets/$phone/balance'),
      );

      // 2. Récupération des Transactions : GET /api/wallets/{phone}/transactions
      final transactionsResponse = await http.get(
        Uri.parse('${AppConstants.baseUrl}/wallets/$phone/transactions'),
      );

      if (balanceResponse.statusCode == 200 && transactionsResponse.statusCode == 200) {
        // Traitement du solde (Exemple si l'API renvoie {"balance": 25000} ou directement le chiffre)
        final balanceData = jsonDecode(balanceResponse.body);
        if (balanceData is Map) {
          _balance = (balanceData['balance'] as num).toDouble();
        } else {
          _balance = (balanceData as num).toDouble();
        }

        // Traitement des transactions (Prendre les 5 dernières pour le Home)
        final List<dynamic> transactionsData = jsonDecode(transactionsResponse.body);
        List<TransactionModel> allTransactions = transactionsData
            .map((json) => TransactionModel.fromJson(json))
            .toList();
            
        // Tri par date décroissante et sélection des 5 premières
        allTransactions.sort((a, b) => b.date.compareTo(a.date));
        _recentTransactions = allTransactions.take(5).toList();

        _status = WalletStatus.loaded;
      } else {
        _errorMessage = "Erreur serveur (${balanceResponse.statusCode})";
        _status = WalletStatus.error;
      }
    } catch (e) {
      _errorMessage = "Impossible de joindre le serveur. Vérifiez votre connexion.";
      _status = WalletStatus.error;
    }

    notifyListeners();
  }
}