import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../models/goal_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(title: const Text('Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar + name
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryDark, AppTheme.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          state.userName.isNotEmpty
                              ? state.userName[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.userName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '🔥 ${state.streak}-day streak',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Stats
                Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                            label: 'Total Goals',
                            value: '${state.goals.length}',
                            icon: '🎯')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                            label: 'Completed',
                            value: '${state.completedGoals.length}',
                            icon: '✅')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                            label: 'Transactions',
                            value: '${state.transactions.length}',
                            icon: '💸')),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  label: 'Total Saved',
                  value: r'₱' + state.totalSaved.toStringAsFixed(2),
                  icon: Icons.savings_rounded,
                  color: AppTheme.success,
                ),
                const SizedBox(height: 10),
                _InfoCard(
                  label: 'Total Target',
                  value: r'₱' + state.totalTarget.toStringAsFixed(2),
                  icon: Icons.flag_rounded,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPage(),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, color: AppTheme.primary, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'View History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppTheme.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SettingsSection(title: 'Account', children: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Name',
                    onTap: () => _editName(context, state),
                  ),
                ]),
                const SizedBox(height: 12),
                _SettingsSection(title: 'Data', children: [
                  _SettingsTile(
                    icon: Icons.delete_forever_rounded,
                    label: 'Reset All Data',
                    color: AppTheme.danger,
                    onTap: () => _confirmReset(context, state),
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editName(BuildContext context, AppState state) {
    final ctrl = TextEditingController(text: state.userName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Your Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                state.updateUserName(ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
            'This will permanently delete all your goals and transactions. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              state.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }
}

// ─── History Page ────────────────────────────────────────────────────────────

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final completed = state.completedHistory.map((map) {
          final goalMap = Map<String, dynamic>.from(map);
          return Goal.fromMap(goalMap);
        }).toList();

        final deleted = state.deletedHistory.map((map) {
          final goalMap = Map<String, dynamic>.from(map);
          return Goal.fromMap(goalMap);
        }).toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('History'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primary,
                  tabs: [
                    Tab(text: 'Completed', icon: Icon(Icons.task_alt)),
                    Tab(text: 'Deleted', icon: Icon(Icons.delete_outline)),
                    Tab(text: 'Transactions', icon: Icon(Icons.receipt_long)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // ── Completed ──
                      completed.isEmpty
                          ? _EmptyState(
                              icon: Icons.task_alt,
                              title: 'No completed goals yet',
                              subtitle: 'Goals you achieve will appear here',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: completed.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final goal = completed[index];
                                final completedDateStr =
                                    goal.toMap()['completedDate'] as String?;
                                final completedDate = completedDateStr != null
                                    ? DateTime.parse(completedDateStr)
                                    : DateTime.now();
                                return _HistoryItem(
                                  goal: goal,
                                  dateLabel: DateFormat('MMM d, yyyy')
                                      .format(completedDate),
                                  status: 'Completed',
                                  statusColor: AppTheme.success,
                                );
                              },
                            ),

                      // ── Deleted Goals ──
                      deleted.isEmpty
                          ? _EmptyState(
                              icon: Icons.delete_outline,
                              title: 'No deleted goals',
                              subtitle: 'Deleted goals will appear here',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: deleted.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final goal = deleted[index];
                                final deletedDateStr =
                                    goal.toMap()['deletedDate'] as String?;
                                final deletedDate = deletedDateStr != null
                                    ? DateTime.parse(deletedDateStr)
                                    : DateTime.now();
                                return _HistoryItem(
                                  goal: goal,
                                  dateLabel: DateFormat('MMM d, yyyy')
                                      .format(deletedDate),
                                  status: 'Deleted',
                                  statusColor: AppTheme.warning,
                                );
                              },
                            ),

                      // ── Deleted Transactions ──
                      state.deletedTransactions.isEmpty
                          ? _EmptyState(
                              icon: Icons.receipt_long,
                              title: 'No deleted transactions',
                              subtitle: 'Deleted transactions will appear here',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.deletedTransactions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final tx = state.deletedTransactions[index];
                                final fmt = NumberFormat('#,##0.00', 'en_PH');

                                // ✅ FIXED: gamitin ang tx.deletedDate directly
                                // hindi na kailangan ng DateTime.parse(toMap()['deletedDate'])
                                // na nag-crash pag null
                                final txDate = tx.deletedDate ?? tx.date;

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: tx.isIncome
                                              ? AppTheme.success
                                                  .withOpacity(0.12)
                                              : AppTheme.danger
                                                  .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          tx.isIncome
                                              ? Icons.arrow_downward_rounded
                                              : Icons.arrow_upward_rounded,
                                          color: tx.isIncome
                                              ? AppTheme.success
                                              : AppTheme.danger,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.description,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              '${tx.goalName} • ${DateFormat('MMM d').format(tx.date)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            DateFormat('MMM d, yyyy')
                                                .format(txDate),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.danger
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Deleted',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.danger,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              )),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              )),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Goal goal;
  final String dateLabel;
  final String status;
  final Color statusColor;

  const _HistoryItem({
    required this.goal,
    required this.dateLabel,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: statusColor.withOpacity(0.12),
            child: Text(goal.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    )),
                Text(
                  '${goal.category} • PHP ${goal.targetAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppTheme.textPrimary,
              )),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: color,
              )),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
