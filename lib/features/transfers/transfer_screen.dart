// lib/features/transfers/transfer_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../dashboard/wallet_provider.dart';
import 'transfer_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitTransfer() async {
    if (_formKey.currentState!.validate()) {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final walletProv = Provider.of<WalletProvider>(context, listen: false);
      final transferProv = Provider.of<TransferProvider>(context, listen: false);

      final senderPhone = authProv.phoneNumber ?? "";
      final receiverPhone = _receiverController.text;
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      final success = await transferProv.makeTransfer(
        senderPhone: senderPhone,
        receiverPhone: receiverPhone,
        amount: amount,
        walletProvider: walletProv, // Transmission indispensable du WalletProvider
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfert effectué avec succès !')),
        );
        Navigator.pop(context); // Retour à l'écran précédent rafraîchi
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(transferProv.errorMessage.isNotEmpty 
            ? transferProv.errorMessage 
            : 'Échec du transfert.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transferProv = context.watch<TransferProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Transférer de l'argent")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _receiverController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro du destinataire',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant à envoyer (XOF)',
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0 
                    ? 'Veuillez entrer un montant valide' 
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: transferProv.isLoading ? null : _submitTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF21409A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: transferProv.isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Confirmer le transfert', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}