// lib/models/bill_model.dart
class BillModel {
  final String id;
  final String provider; // SENELEC, WOYAFAL, etc.
  final double amount;
  final String month;
  final String billNumber;

  BillModel({
    required this.id,
    required this.provider,
    required this.amount,
    required this.month,
    required this.billNumber,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id']?.toString() ?? '',
      provider: json['provider'] ?? 'Inconnu',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      month: json['month'] ?? '',
      billNumber: json['billNumber'] ?? '',
    );
  }
}