import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';

void showAddTransactionSheet(BuildContext context,
    {double? prefillAmount,
    TransactionType prefillType = TransactionType.income}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddTransactionSheet(
      prefillAmount: prefillAmount,
      prefillType: prefillType,
    ),
  );
}

class AddTransactionSheet extends StatefulWidget {
  final double? prefillAmount;
  final TransactionType prefillType;

  const AddTransactionSheet({
    super.key,
    this.prefillAmount,
    this.prefillType = TransactionType.income,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedGoalId;
  late TransactionType _type;

  @override
  void initState() {
    super.initState();
    _type = widget.prefillType;
    if (widget.prefillAmount != null) {
      _amountCtrl.text = widget.prefillAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState state) async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0 || _selectedGoalId == null) return;

    final success = await state.addTransaction(
      goalId: _selectedGoalId!,
      description: _descCtrl.text.isEmpty ? 'Transaction' : _descCtrl.text,
      amount: amount,
      type: _type,
    );

    if (!mounted) return;
    Navigator.pop(context);

    await Future.delayed(const Duration(milliseconds: 100));

    final goal = state.goals.firstWhere((g) => g.id == _selectedGoalId!);

    if (success && goal.isCompleted) {
      final timeTaken = await state.markGoalCompleted(goal.id);
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.celebration, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text(
                'Goal Achieved!',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                goal.emoji + ' ' + goal.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '🎉 Congratulations! Goal Achieved!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'You reached ₱${goal.targetAmount.toStringAsFixed(0)} target in $timeTaken!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(context),
              child: const Text('Awesome!'),
            ),
          ],
        ),
      );
      return;
    }

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_type == TransactionType.income
              ? '₱${amount.toStringAsFixed(0)} added!'
              : '₱${amount.toStringAsFixed(0)} withdrawn.'),
          backgroundColor: _type == TransactionType.income
              ? AppTheme.success
              : AppTheme.danger,
          duration: const Duration(seconds: 2),
        ));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot withdraw more than saved or on completed goal'),
          backgroundColor: AppTheme.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final goals = state.goals;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Add Transaction',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2937))),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  _TypeButton(
                    label: 'Add Savings',
                    icon: Icons.add_circle_outline_rounded,
                    color: AppTheme.success,
                    selected: _type == TransactionType.income,
                    onTap: () => setState(() => _type = TransactionType.income),
                  ),
                  _TypeButton(
                    label: 'Withdraw',
                    icon: Icons.remove_circle_outline_rounded,
                    color: AppTheme.danger,
                    selected: _type == TransactionType.withdraw,
                    onTap: () =>
                        setState(() => _type = TransactionType.withdraw),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (goals.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Create a goal first before adding transactions.',
                    style: TextStyle(color: Color(0xFF6B7280))),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedGoalId,
                hint: const Text('Select Goal'),
                decoration: const InputDecoration(labelText: 'Goal'),
                items: goals.map((g) {
                  final fmt = NumberFormat('#,##0', 'en_PH');
                  final remaining = g.remaining;
                  final percent = (g.progressPercent * 100).toStringAsFixed(0);
                  String subtitle = g.isCompleted
                      ? 'Done ✓'
                      : '₱${fmt.format(remaining)} left ($percent%)';
                  return DropdownMenuItem<String>(
                    value: g.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: Text('${g.emoji} ${g.name}')),
                        const Spacer(),
                        Flexible(
                            child: Text(subtitle,
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF6B7280)))),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedGoalId = v),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Amount', prefixText: '₱ '),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedGoalId != null &&
                        double.tryParse(_amountCtrl.text) != null
                    ? () => _submit(state)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == TransactionType.income
                      ? AppTheme.success
                      : AppTheme.danger,
                ),
                child: Text(_type == TransactionType.income
                    ? 'Add Savings'
                    : 'Record Withdrawal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? color : AppTheme.textSecondary, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: selected ? color : AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
