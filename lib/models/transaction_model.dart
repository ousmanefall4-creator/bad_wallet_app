// lib/models/transaction_model.dart

class TransactionModel {
  final String id;
  final String type; // 'TRANSFER_SENT', 'TRANSFER_RECEIVED', 'BILL_PAYMENT', etc.
  final double amount;
  final String description;
  final DateTime date;
  final String? receiverOrProvider;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.receiverOrProvider,
  });

  // Convertir le JSON de l'API en objet Dart
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'UNKNOWN',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      receiverOrProvider: json['receiverOrProvider'],
    );
  }
}