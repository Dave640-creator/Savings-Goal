// lib/services/app_state.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';
import 'storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();

  List<Goal> _goals = [];
  List<Transaction> _transactions = [];
  String _userName = 'Saver';
  int _streak = 0;
  bool _isLoaded = false;

  List<Goal> get goals => _goals;
  List<Transaction> get transactions => _transactions;
  String get userName => _userName;
  int get streak => _streak;
  bool get isLoaded => _isLoaded;

  double get totalSaved => _goals.fold(0.0, (sum, g) => sum + g.savedAmount);

  double get totalTarget => _goals.fold(0.0, (sum, g) => sum + g.targetAmount);

  int get completedGoals => _goals.where((g) => g.isCompleted).length;

  Future<void> init() async {
    _goals = await _storage.loadGoals();
    _transactions = await _storage.loadTransactions();
    _userName = await _storage.loadUserName();
    _streak = await _storage.loadStreak();
    _isLoaded = true;
    notifyListeners();
  }

  // ── Goals ──────────────────────────────────────────────

  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> updateGoal(Goal updated) async {
    final idx = _goals.indexWhere((g) => g.id == updated.id);
    if (idx != -1) {
      _goals[idx] = updated;
      await _storage.saveGoals(_goals);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    _transactions.removeWhere((t) => t.goalId == goalId);
    await _storage.saveGoals(_goals);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  // ── Transactions ───────────────────────────────────────

  Future<void> addTransaction({
    required String goalId,
    required String description,
    required double amount,
    required TransactionType type,
  }) async {
    final goal = _goals.firstWhere((g) => g.id == goalId);

    final tx = Transaction(
      id: _uuid.v4(),
      goalId: goalId,
      goalName: goal.name,
      description: description,
      amount: amount,
      type: type,
      date: DateTime.now(),
    );

    // Update goal's saved amount
    if (type == TransactionType.income) {
      goal.savedAmount += amount;
    } else {
      goal.savedAmount =
          (goal.savedAmount - amount).clamp(0.0, double.infinity);
    }

    _transactions.insert(0, tx);
    await _storage.saveGoals(_goals);
    await _storage.saveTransactions(_transactions);
    await _storage.updateStreak();
    _streak = await _storage.loadStreak();
    notifyListeners();
  }

  Future<void> deleteTransaction(String txId) async {
    final tx = _transactions.firstWhere((t) => t.id == txId);
    final goal = _goals.firstWhere((g) => g.id == tx.goalId,
        orElse: () => Goal(
            id: '',
            name: '',
            targetAmount: 0,
            startDate: DateTime.now(),
            targetDate: DateTime.now()));

    if (goal.id.isNotEmpty) {
      if (tx.isIncome) {
        goal.savedAmount =
            (goal.savedAmount - tx.amount).clamp(0.0, double.infinity);
      } else {
        goal.savedAmount += tx.amount;
      }
    }

    _transactions.removeWhere((t) => t.id == txId);
    await _storage.saveGoals(_goals);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  // ── Profile ────────────────────────────────────────────

  Future<void> updateUserName(String name) async {
    _userName = name;
    await _storage.saveUserName(name);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _storage.clearAll();
    _goals = [];
    _transactions = [];
    _userName = 'Saver';
    _streak = 0;
    notifyListeners();
  }

  // ── Monthly savings data for chart ────────────────────

  List<Map<String, dynamic>> getMonthlySavings({int months = 6}) {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      double income = 0;
      double withdrawn = 0;

      for (final tx in _transactions) {
        if (tx.date.isAfter(month) && tx.date.isBefore(nextMonth)) {
          if (tx.isIncome) {
            income += tx.amount;
          } else {
            withdrawn += tx.amount;
          }
        }
      }

      result.add({
        'month': month,
        'income': income,
        'withdrawn': withdrawn,
      });
    }

    return result;
  }

  String newGoalId() => _uuid.v4();
}
