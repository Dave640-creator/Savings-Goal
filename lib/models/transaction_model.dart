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

  Transaction({
    required this.id,
    required this.goalId,
    required this.goalName,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
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
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'],
        goalId: map['goalId'],
        goalName: map['goalName'],
        description: map['description'],
        amount: map['amount'],
        type: map['type'] == 'income'
            ? TransactionType.income
            : TransactionType.withdraw,
        date: DateTime.parse(map['date']),
      );

  String toJson() => jsonEncode(toMap());
  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(jsonDecode(source));
}
