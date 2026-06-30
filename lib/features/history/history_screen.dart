// lib/features/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bad_wallet_app/features/auth/auth_provider.dart';
import 'package:bad_wallet_app/features/dashboard/wallet_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF21409A),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authProvider.phoneNumber != null) {
            await walletProvider.fetchWalletData(authProvider.phoneNumber!);
          }
        },
        child: walletProvider.recentTransactions.isEmpty
            ? const Center(
                child: Text(
                  'Aucune transaction enregistrée.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: walletProvider.recentTransactions.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final tx = walletProvider.recentTransactions[index];
                  // Vérification du type pour appliquer les codes couleurs imposés
                  final isExpense = tx.type.contains('SENT') || tx.type.contains('PAYMENT');

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isExpense ? Colors.red.shade50 : Colors.green.shade50,
                      child: Icon(
                        isExpense ? Icons.arrow_outward : Icons.call_received,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      tx.description,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(tx.date),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    trailing: Text(
                      '${isExpense ? "-" : "+"}${currencyFormat.format(tx.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isExpense ? Colors.red : Colors.green, // Code couleur du barème
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}