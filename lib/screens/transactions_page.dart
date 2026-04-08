// lib/screens/transactions_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../widgets/add_transaction_sheet.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final transactions = state.transactions;
        final totalIn = transactions
            .where((t) => t.isIncome)
            .fold(0.0, (s, t) => s + t.amount);
        final totalOut = transactions
            .where((t) => !t.isIncome)
            .fold(0.0, (s, t) => s + t.amount);

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(title: const Text('Transactions')),
          body: Column(
            children: [
              // Summary strip
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                        child: _SummaryTile(
                            label: 'Total In',
                            amount: totalIn,
                            color: AppTheme.success,
                            icon: Icons.arrow_downward_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _SummaryTile(
                            label: 'Total Out',
                            amount: totalOut,
                            color: AppTheme.danger,
                            icon: Icons.arrow_upward_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _SummaryTile(
                            label: 'Net Savings',
                            amount: totalIn - totalOut,
                            color: AppTheme.primary,
                            icon: Icons.account_balance_wallet_rounded)),
                  ],
                ),
              ),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('💸', style: TextStyle(fontSize: 52)),
                            SizedBox(height: 12),
                            Text('No transactions yet',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary)),
                            Text('Add one using the button below',
                                style:
                                    TextStyle(color: AppTheme.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => _TxTile(
                          tx: transactions[i],
                          onDelete: () =>
                              state.deleteTransaction(transactions[i].id),
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddTransactionSheet(context),
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Transaction',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryTile(
      {required this.label,
      required this.amount,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_PH');
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
          Text(
            '₱${fmt.format(amount)}',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Transaction tx;
  final VoidCallback onDelete;

  const _TxTile({required this.tx, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_PH');
    final isIncome = tx.isIncome;

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text(
                'Remove this transaction? The goal balance will be reversed.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isIncome
                    ? AppTheme.success.withOpacity(0.12)
                    : AppTheme.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isIncome ? AppTheme.success : AppTheme.danger,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    '${tx.goalName} • ${DateFormat('MMM d, h:mm a').format(tx.date)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}₱${fmt.format(tx.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: isIncome ? AppTheme.success : AppTheme.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
