import 'dart:convert';
import 'package:intl/intl.dart';

class Goal {
  final String id;
  String name;
  String emoji;
  double targetAmount;
  double savedAmount;
  DateTime startDate;
  DateTime targetDate;
  String category;
  String? imageData; // base64 encoded JPEG thumbnail

  Goal({
    required this.id,
    required this.name,
    this.emoji = '🎯',
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.startDate,
    required this.targetDate,
    this.category = 'General',
    this.imageData,
  });

  // ✅ FIXED: guard against targetAmount = 0 (NaN)
  double get progressPercent =>
      targetAmount <= 0 ? 0.0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  double get remaining =>
      (targetAmount - savedAmount).clamp(0.0, double.infinity);

  // ✅ FIXED: guard against targetAmount = 0 (always-true bug)
  bool get isCompleted => targetAmount > 0 && savedAmount >= targetAmount;

  int get monthsRemaining {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    return ((targetDate.year - now.year) * 12 + (targetDate.month - now.month))
        .clamp(0, 999);
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    if (targetDay.isBefore(today)) return 0;
    return targetDay.difference(today).inDays;
  }

  double get monthlyTarget {
    final months = monthsRemaining;
    if (months <= 0) return remaining;
    return remaining / months;
  }

  // ✅ FIXED: guard against weeks < 1 to avoid inflated amount
  double get weeklyTarget {
    final days = daysRemaining;
    if (days <= 0) return remaining / 4.345;
    final weeks = days / 7.0;
    if (weeks < 1) return remaining; // less than 1 week na, bayaran na lahat
    return remaining / weeks;
  }

  double get dailyTarget {
    final days = daysRemaining;
    if (days <= 0) return remaining / 30.437;
    return remaining / days;
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

  /// Smart target based on time remaining
  String get smartTargetLabel {
    final days = daysRemaining;
    final fmt = NumberFormat('#,##0', 'en_PH');

    if (days <= 0) return 'Target reached or overdue';
    if (days < 30) {
      return '₱${fmt.format(dailyTarget)}/day needed';
    } else if (days < 90) {
      return '₱${fmt.format(weeklyTarget)}/week needed';
    } else {
      return '₱${fmt.format(monthlyTarget)}/month needed';
    }
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
        if (imageData != null) 'imageData': imageData,
      };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
        id: map['id'] as String,
        name: map['name'] as String,
        emoji: map['emoji'] ?? '🎯',
        targetAmount: (map['targetAmount'] as num).toDouble(),
        savedAmount: (map['savedAmount'] as num).toDouble(),
        startDate: DateTime.parse(map['startDate'] as String),
        targetDate: DateTime.parse(map['targetDate'] as String),
        category: map['category'] ?? 'General',
        imageData: map['imageData'] as String?,
      );

  String toJson() => jsonEncode(toMap());
  factory Goal.fromJson(String source) => Goal.fromMap(jsonDecode(source));
}
