// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';
import '../widgets/add_transaction_sheet.dart';
import 'goals_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.isLoaded) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, state),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SummaryCard(state: state),
                    const SizedBox(height: 20),
                    _StreakBanner(streak: state.streak),
                    const SizedBox(height: 20),
                    _QuickSaveSection(state: state),
                    const SizedBox(height: 20),
                    _SavingsChartCard(state: state),
                    const SizedBox(height: 20),
                    _ActiveGoalsPreview(state: state),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AppState state) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.background,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting,',
            style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500),
          ),
          Text(
            state.userName,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.12),
            child: Text(
              state.userName.isNotEmpty ? state.userName[0].toUpperCase() : 'S',
              style: const TextStyle(
                  color: AppTheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final AppState state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_PH');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL SAVED',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  // ✅ FIXED: .length added — completedGoals is List<Goal> not int
                  '${state.completedGoals.length}/${state.goals.length} goals done',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₱${fmt.format(state.totalSaved)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overall Progress',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  Text(
                    state.totalTarget > 0
                        ? '${((state.totalSaved / state.totalTarget) * 100).toStringAsFixed(0)}%'
                        : '0%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: state.totalTarget > 0
                      ? (state.totalSaved / state.totalTarget).clamp(0.0, 1.0)
                      : 0,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Streak Banner ─────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  final int streak;
  const _StreakBanner({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak-Day Saving Streak!',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFC2410C),
                    fontSize: 14),
              ),
              Text(
                streak == 0
                    ? 'Start saving today to begin your streak!'
                    : 'Keep it up! Save again tomorrow.',
                style: const TextStyle(color: Color(0xFF9A3412), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Save Section ────────────────────────────────────────────────────────

class _QuickSaveSection extends StatelessWidget {
  final AppState state;
  const _QuickSaveSection({required this.state});

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: use activeGoals — exclude completed goals from quick save
    final activeGoals = state.activeGoals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Save',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        if (activeGoals.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('Create a goal first to quick-save!',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
          )
        else
          Row(
            children: [
              for (final amount in [50.0, 100.0, 500.0])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _QuickSaveBtn(
                        amount: amount, goals: activeGoals, state: state),
                  ),
                ),
              Expanded(
                child: _CustomSaveBtn(goals: activeGoals, state: state),
              ),
            ],
          ),
      ],
    );
  }
}

class _QuickSaveBtn extends StatelessWidget {
  final double amount;
  final List<Goal> goals;
  final AppState state;
  const _QuickSaveBtn(
      {required this.amount, required this.goals, required this.state});

  void _save(BuildContext context) {
    if (goals.length == 1) {
      context.read<AppState>().addTransaction(
            goalId: goals.first.id,
            description: 'Quick Save',
            amount: amount,
            type: TransactionType.income,
          );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('₱${amount.toStringAsFixed(0)} added to ${goals.first.name}!'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ));
    } else {
      showAddTransactionSheet(context,
          prefillAmount: amount, prefillType: TransactionType.income);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _save(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        side: const BorderSide(color: AppTheme.divider),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text('+₱${amount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }
}

class _CustomSaveBtn extends StatelessWidget {
  final List<Goal> goals;
  final AppState state;
  const _CustomSaveBtn({required this.goals, required this.state});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showAddTransactionSheet(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Custom',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }
}

// ── Savings Chart ─────────────────────────────────────────────────────────────

class _SavingsChartCard extends StatelessWidget {
  final AppState state;
  const _SavingsChartCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final data = state.getMonthlySavings();

    // ✅ FIXED: safe maxY — no crash pag empty or lahat zero
    final maxIncome = data.isEmpty
        ? 0.0
        : data
            .map((d) => d['income'] as double)
            .reduce((a, b) => a > b ? a : b);
    final maxY = maxIncome * 1.3 + 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Savings',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          const Text('Last 6 months activity',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final month = data[idx]['month'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('MMM').format(month),
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.textSecondary),
                          ),
                        );
                      },
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.divider,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i]['income'] as double,
                        color: AppTheme.primary,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active Goals Preview ──────────────────────────────────────────────────────

class _ActiveGoalsPreview extends StatelessWidget {
  final AppState state;
  const _ActiveGoalsPreview({required this.state});

  @override
  Widget build(BuildContext context) {
    final activeGoals = state.goals.where((g) => !g.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Active Goals',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const GoalsPage()));
              },
              child: const Text('See all',
                  style: TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (activeGoals.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
                child: Text('No active goals yet. Create one! 🎯',
                    style: TextStyle(color: AppTheme.textSecondary))),
          )
        else
          // Vertical list showing all active goals
          Column(
            children: activeGoals.map((goal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CompactGoalCard(goal: goal),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// Compact goal card for home page preview
class _CompactGoalCard extends StatelessWidget {
  final Goal goal;
  const _CompactGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_PH');
    final Color progressColor = goal.progressPercent < 0.4
        ? AppTheme.warning
        : goal.progressPercent < 0.8
            ? AppTheme.primary
            : AppTheme.success;

    // Get image or emoji
    Widget imageWidget;
    if (goal.imageData != null) {
      try {
        imageWidget = CircleAvatar(
          radius: 18,
          backgroundImage: MemoryImage(base64Decode(goal.imageData!)),
        );
      } catch (_) {
        imageWidget = CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Text(goal.emoji, style: const TextStyle(fontSize: 16)),
        );
      }
    } else {
      imageWidget = CircleAvatar(
        radius: 18,
        backgroundColor: AppTheme.primary.withOpacity(0.1),
        child: Text(goal.emoji, style: const TextStyle(fontSize: 16)),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              imageWidget,
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppTheme.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progressPercent,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(goal.progressPercent * 100).toStringAsFixed(0)}% • ₱${fmt.format(goal.savedAmount)}',
            style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
