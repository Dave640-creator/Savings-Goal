// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final fmt = NumberFormat('#,##0.00', 'en_PH');

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
                            value: '${state.completedGoals}',
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
                  value: '₱${fmt.format(state.totalSaved)}',
                  icon: Icons.savings_rounded,
                  color: AppTheme.success,
                ),
                const SizedBox(height: 10),
                _InfoCard(
                  label: 'Total Target',
                  value: '₱${fmt.format(state.totalTarget)}',
                  icon: Icons.flag_rounded,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 20),
                // Edit name
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
                const SizedBox(height: 20),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

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
              offset: const Offset(0, 2)),
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
                  color: AppTheme.textPrimary)),
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

  const _InfoCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

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
              offset: const Offset(0, 2)),
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
                  fontWeight: FontWeight.w800, fontSize: 15, color: color)),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
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
