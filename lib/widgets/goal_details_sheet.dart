import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../core/app_theme.dart';
import '../../models/goal_model.dart';
import '../../models/transaction_model.dart';
import '../../services/app_state.dart';
import 'add_transaction_sheet.dart';

class GoalDetailsSheet extends StatelessWidget {
  final Goal goal;

  const GoalDetailsSheet({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_PH');
    final state = context.read<AppState>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Image or emoji
              if (goal.imageData != null)
                CircleAvatar(
                  radius: 28,
                  backgroundImage: MemoryImage(base64Decode(goal.imageData!)),
                )
              else
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900)),
                    Text('${goal.category} Goal',
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Deadline info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target Deadline',
                              style: TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary)),
                          Text(
                            DateFormat('MMMM d, yyyy').format(goal.targetDate),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      goal.statusLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: goal.isCompleted
                              ? AppTheme.success
                              : goal.daysRemaining <= 30
                                  ? AppTheme.danger
                                  : AppTheme.primary),
                    ),
                  ],
                ),
                // Show start and completion dates for completed goals
                if (goal.isCompleted) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Started',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                            Text(
                              DateFormat('MMM d, yyyy').format(goal.startDate),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Completed',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                            Text(
                              DateFormat('MMM d, yyyy').format(DateTime.now()),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.success),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Progress section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: goal.isCompleted
                  ? AppTheme.success.withOpacity(0.08)
                  : AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('${(goal.progressPercent * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: goal.progressPercent,
                    backgroundColor: AppTheme.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        goal.isCompleted ? AppTheme.success : AppTheme.primary),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressChip(
                        label: 'Saved',
                        value: '₱${fmt.format(goal.savedAmount)}',
                        total: '₱${fmt.format(goal.targetAmount)}',
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ProgressChip(
                        label: 'Remaining',
                        value: '₱${fmt.format(goal.remaining)}',
                        color: AppTheme.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Actions (only show if goal is not completed)
          if (!goal.isCompleted) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close details sheet first
                      showAddTransactionSheet(
                        context,
                        prefillAmount: 0,
                        prefillType: TransactionType.income,
                        goalId: goal.id, // Pre-select this goal
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success),
                    icon: const Icon(Icons.add_circle_rounded,
                        color: Colors.white),
                    label: const Text('Add Cash',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: goal.savedAmount > 0
                        ? () {
                            Navigator.pop(context); // Close details sheet first
                            showAddTransactionSheet(
                              context,
                              prefillAmount: 0,
                              prefillType: TransactionType.withdraw,
                              goalId: goal.id, // Pre-select this goal
                            );
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.danger)),
                    icon: const Icon(Icons.remove_circle_rounded,
                        color: AppTheme.danger),
                    label: const Text('Withdraw',
                        style: TextStyle(color: AppTheme.danger)),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Show completion info for completed goals
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.celebration,
                      color: AppTheme.success, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    '🎉 Goal Completed!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.success),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This goal has been achieved. No further transactions allowed.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final String label;
  final String value;
  final String? total;
  final Color color;

  const _ProgressChip({
    required this.label,
    required this.value,
    this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          if (total != null) ...[
            const SizedBox(height: 2),
            Text(total!,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ],
      ),
    );
  }
}
