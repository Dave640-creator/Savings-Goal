// lib/models/transaction_model.dart
import 'dart:convert';

enum TransactionType { income, withdraw }

class Transaction {
  final String id;
  final String goalId;
  final String goalName;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final DateTime? deletedDate; // ← ADDED

  Transaction({
    required this.id,
    required this.goalId,
    required this.goalName,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.deletedDate, // ← optional, hindi required
  });

  bool get isIncome => type == TransactionType.income;

  Map<String, dynamic> toMap() => {
        'id': id,
        'goalId': goalId,
        'goalName': goalName,
        'description': description,
        'amount': amount,
        'type': type.name,
        'date': date.toIso8601String(),
        'deletedDate': deletedDate?.toIso8601String(), // ← null-safe save
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as String,
        goalId: map['goalId'] as String,
        goalName: map['goalName'] as String,
        description: map['description'] as String,
        amount: (map['amount'] as num).toDouble(),
        type: map['type'] == 'income'
            ? TransactionType.income
            : TransactionType.withdraw,
        date: DateTime.parse(map['date'] as String),
        deletedDate: map['deletedDate'] != null // ← null-safe load
            ? DateTime.parse(map['deletedDate'] as String)
            : null,
      );

  String toJson() => jsonEncode(toMap());
  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(jsonDecode(source));
}
