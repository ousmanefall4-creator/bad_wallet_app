// lib/features/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bad_wallet_app/features/auth/auth_provider.dart';
import 'package:bad_wallet_app/features/auth/login_screen.dart';
import 'wallet_provider.dart';

// Importations des écrans cibles pour les boutons d'actions
import 'package:bad_wallet_app/features/transfers/transfer_screen.dart';
import 'package:bad_wallet_app/features/bills/bills_screen.dart';
import 'package:bad_wallet_app/features/history/history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceVisible = false; // Gestion du masquage du solde (icône œil)
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Chargement automatique des données (Solde + 5 transactions) au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final phone = Provider.of<AuthProvider>(context, listen: false).phoneNumber;
      if (phone != null) {
        Provider.of<WalletProvider>(context, listen: false).fetchWalletData(phone);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final walletProvider = context.watch<WalletProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BadWallet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF21409A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authProvider.phoneNumber != null) {
            await walletProvider.fetchWalletData(authProvider.phoneNumber!);
          }
        },
        child: _buildBody(walletProvider),
      ),
    );
  }

  // Gestion des 3 états imposés par l'énoncé de l'examen
  Widget _buildBody(WalletProvider provider) {
    switch (provider.status) {
      case WalletStatus.loading:
        return const Center(child: CircularProgressIndicator());
        
      case WalletStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  provider.errorMessage, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16)
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final phone = Provider.of<AuthProvider>(context, listen: false).phoneNumber;
                  if (phone != null) provider.fetchWalletData(phone);
                },
                child: const Text('Réessayer'),
              )
            ],
          ),
        );

      case WalletStatus.loaded:
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CARTE DU SOLDE (Masquable via l'icône œil)
              Card(
                color: const Color(0xFF21409A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Solde disponible', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          IconButton(
                            icon: Icon(_isBalanceVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white),
                            onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isBalanceVisible ? currencyFormat.format(provider.balance) : '••••••• XOF',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. BOUTONS D'ACTIONS RAPIDES (Raccordés aux écrans)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionButton(Icons.send, 'Transférer', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TransferScreen()),
                    );
                  }),
                  _actionButton(Icons.receipt_long, 'Payer', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BillsScreen()),
                    );
                  }),
                  _actionButton(Icons.history, 'Historique', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryScreen()),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 32),

              // 3. APERÇU DES 5 DERNIÈRES TRANSACTIONS
              const Text('Dernières opérations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              provider.recentTransactions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('Aucune transaction récente', style: TextStyle(color: Colors.grey))),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.recentTransactions.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final tx = provider.recentTransactions[index];
                        final isSend = tx.type.contains('SENT') || tx.type.contains('PAYMENT');
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSend ? Colors.red.shade50 : Colors.green.shade50,
                            child: Icon(isSend ? Icons.arrow_outward : Icons.call_received, 
                                        color: isSend ? Colors.red : Colors.green),
                          ),
                          title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(tx.date)),
                          trailing: Text(
                            '${isSend ? "-" : "+"}${currencyFormat.format(tx.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSend ? Colors.red : Colors.green, // Code couleur exigé
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
    }
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFFD200).withOpacity(0.2),
            child: Icon(icon, color: const Color(0xFF21409A), size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}