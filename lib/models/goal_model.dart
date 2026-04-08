// lib/models/goal_model.dart
import 'dart:convert';

class Goal {
  final String id;
  String name;
  String emoji;
  double targetAmount;
  double savedAmount;
  DateTime startDate;
  DateTime targetDate;
  String category;

  Goal({
    required this.id,
    required this.name,
    this.emoji = '🎯',
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.startDate,
    required this.targetDate,
    this.category = 'General',
  });

  double get progressPercent => (savedAmount / targetAmount).clamp(0.0, 1.0);

  double get remaining =>
      (targetAmount - savedAmount).clamp(0.0, double.infinity);

  bool get isCompleted => savedAmount >= targetAmount;

  int get monthsRemaining {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    return ((targetDate.year - now.year) * 12 + (targetDate.month - now.month))
        .clamp(0, 999);
  }

  double get monthlyTarget {
    final months = monthsRemaining;
    if (months <= 0) return remaining;
    return remaining / months;
  }

  int get totalMonths {
    return ((targetDate.year - startDate.year) * 12 +
            (targetDate.month - startDate.month))
        .clamp(1, 999);
  }

  String get statusLabel {
    if (isCompleted) return 'Completed 🎉';
    final months = monthsRemaining;
    if (months == 0) return 'Overdue!';
    if (months <= 1) return 'Due this month!';
    return '$months months left';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'startDate': startDate.toIso8601String(),
        'targetDate': targetDate.toIso8601String(),
        'category': category,
      };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
        id: map['id'],
        name: map['name'],
        emoji: map['emoji'] ?? '🎯',
        targetAmount: map['targetAmount'],
        savedAmount: map['savedAmount'],
        startDate: DateTime.parse(map['startDate']),
        targetDate: DateTime.parse(map['targetDate']),
        category: map['category'] ?? 'General',
      );

  String toJson() => jsonEncode(toMap());
  factory Goal.fromJson(String source) => Goal.fromMap(jsonDecode(source));
}
