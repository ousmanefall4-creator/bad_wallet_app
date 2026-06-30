// lib/features/bills/bills_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../dashboard/wallet_provider.dart';
import 'bills_provider.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final _refController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedBillType = 'Électricité';

  @override
  void dispose() {
    _refController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitPayment() async {
    if (_formKey.currentState!.validate()) {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final walletProv = Provider.of<WalletProvider>(context, listen: false);
      final billsProv = Provider.of<BillsProvider>(context, listen: false);

      final phone = authProv.phoneNumber ?? "";
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      final success = await billsProv.payBill(
        phone: phone,
        billType: _selectedBillType,
        amount: amount,
        billReference: _refController.text,
        walletProvider: walletProv, // Transmission indispensable du WalletProvider
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facture réglée avec succès !')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(billsProv.errorMessage.isNotEmpty 
            ? billsProv.errorMessage 
            : 'Échec du paiement.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final billsProv = context.watch<BillsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Régler une facture')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedBillType,
                decoration: const InputDecoration(labelText: 'Type de facture', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Électricité', child: Text('Électricité (SENELEC)')),
                  DropdownMenuItem(value: 'Eau', child: Text('Eau (SEN\'EAU)')),
                  DropdownMenuItem(value: 'Internet', child: Text('Internet/Téléphonie')),
                ],
                onChanged: (v) => setState(() => _selectedBillType = v ?? 'Électricité'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _refController,
                decoration: const InputDecoration(
                  labelText: 'Référence de la facture',
                  prefixIcon: Icon(Icons.receipt),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant de la facture (XOF)',
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0 
                    ? 'Veuillez entrer un montant valide' 
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: billsProv.isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF21409A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: billsProv.isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Payer la facture', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}