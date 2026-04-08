// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const _goalsKey = 'goals_v2';
  static const _transactionsKey = 'transactions_v2';
  static const _userNameKey = 'user_name';
  static const _savingStreakKey = 'saving_streak';
  static const _lastSaveDateKey = 'last_save_date';

  // ── Goals ──────────────────────────────────────────────

  Future<List<Goal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_goalsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Goal.fromMap(e)).toList();
  }

  Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _goalsKey, jsonEncode(goals.map((g) => g.toMap()).toList()));
  }

  // ── Transactions ───────────────────────────────────────

  Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_transactionsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Transaction.fromMap(e)).toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_transactionsKey,
        jsonEncode(transactions.map((t) => t.toMap()).toList()));
  }

  // ── User Profile ───────────────────────────────────────

  Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Saver';
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  // ── Streak ─────────────────────────────────────────────

  Future<int> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_savingStreakKey) ?? 0;
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRaw = prefs.getString(_lastSaveDateKey);
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (lastRaw == null) {
      await prefs.setInt(_savingStreakKey, 1);
      await prefs.setString(_lastSaveDateKey, todayStr);
      return;
    }

    final last = DateTime.parse(lastRaw);
    final diff = today.difference(last).inDays;

    if (diff == 0) return; // Same day, no update
    if (diff == 1) {
      // Consecutive day
      final streak = (prefs.getInt(_savingStreakKey) ?? 0) + 1;
      await prefs.setInt(_savingStreakKey, streak);
    } else {
      // Streak broken
      await prefs.setInt(_savingStreakKey, 1);
    }
    await prefs.setString(_lastSaveDateKey, todayStr);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
