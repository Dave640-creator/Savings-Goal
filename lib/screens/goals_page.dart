import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img_lib;
import '../core/app_theme.dart';
import '../models/goal_model.dart';
import '../services/app_state.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('My Goals'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_rounded,
                  color: AppTheme.primary, size: 28),
              onPressed: () => _showGoalForm(context, state),
            ),
          ],
        ),
        body: state.goals.isEmpty
            ? _EmptyGoals(onAdd: () => _showGoalForm(context, state))
            : Column(
                children: [
                  _GoalsPieChart(goals: state.goals),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: state.goals.length,
                      itemBuilder: (ctx, i) => _GoalCard(
                        goal: state.goals[i],
                        onEdit: () => _showGoalForm(context, state,
                            existing: state.goals[i]),
                        onDelete: () =>
                            _confirmDelete(context, state, state.goals[i]),
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: state.goals.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => _showGoalForm(context, state),
                backgroundColor: AppTheme.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Goal',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              )
            : null,
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, Goal goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text(
            'Delete "${goal.name}"? This will also remove all related transactions.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              state.deleteGoal(goal.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showGoalForm(BuildContext context, AppState state, {Goal? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalFormSheet(state: state, existing: existing),
    );
  }
}

// ── Pie Chart ─────────────────────────────────────────────────────────────────

class _GoalsPieChart extends StatefulWidget {
  final List<Goal> goals;
  const _GoalsPieChart({required this.goals});

  @override
  State<_GoalsPieChart> createState() => _GoalsPieChartState();
}

class _GoalsPieChartState extends State<_GoalsPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_PH');
    return Container(
      height: 200,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex =
                          response?.touchedSection?.touchedSectionIndex ?? -1;
                    });
                  },
                ),
                sections: List.generate(widget.goals.length, (i) {
                  final g = widget.goals[i];
                  final isTouched = i == _touchedIndex;
                  return PieChartSectionData(
                    value: g.savedAmount > 0 ? g.savedAmount : 1,
                    color:
                        AppTheme.chartColors[i % AppTheme.chartColors.length],
                    radius: isTouched ? 65 : 55,
                    title: isTouched
                        ? '${(g.progressPercent * 100).toStringAsFixed(0)}%'
                        : '',
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  );
                }),
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                widget.goals.length.clamp(0, 5),
                (i) {
                  final g = widget.goals[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme
                                .chartColors[i % AppTheme.chartColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${g.emoji} ${g.name}',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₱${fmt.format(g.savedAmount)}',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Goal Card ─────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalCard(
      {required this.goal, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_PH');
    final Color progressColor = goal.progressPercent < 0.4
        ? AppTheme.warning
        : goal.progressPercent < 0.8
            ? AppTheme.primary
            : AppTheme.success;

    Widget? imageWidget;
    if (goal.imageData != null) {
      try {
        imageWidget = CircleAvatar(
          radius: 26,
          backgroundImage: MemoryImage(base64Decode(goal.imageData!)),
        );
      } catch (e) {
        imageWidget = Text(goal.emoji, style: const TextStyle(fontSize: 26));
      }
    } else {
      imageWidget = Text(goal.emoji, style: const TextStyle(fontSize: 26));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                imageWidget,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppTheme.textPrimary)),
                      Text(goal.category,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert,
                      color: AppTheme.textSecondary),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: AppTheme.danger))),
                  ],
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progressPercent,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 10),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  label: 'Saved',
                  value: '₱${fmt.format(goal.savedAmount)}',
                  color: AppTheme.success,
                ),
                _StatChip(
                  label: 'Target',
                  value: '₱${fmt.format(goal.targetAmount)}',
                  color: AppTheme.primary,
                ),
                _StatChip(
                  label: 'Remaining',
                  value: '₱${fmt.format(goal.remaining)}',
                  color: AppTheme.warning,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Deadline + Monthly target
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Deadline: ${DateFormat('MMM d, yyyy').format(goal.targetDate)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const Spacer(),
                  const Icon(Icons.trending_up_rounded,
                      size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '₱${fmt.format(goal.monthlyTarget)}/month needed',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            if (goal.isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('🎉 Goal Achieved!',
                        style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyGoals extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGoals({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('No goals yet',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(
                'Set a goal with a deadline and we\'ll tell you how much to save every month.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Create My First Goal'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Goal Form Sheet ───────────────────────────────────────────────────────────

class _GoalFormSheet extends StatefulWidget {
  final AppState state;
  final Goal? existing;

  const _GoalFormSheet({required this.state, this.existing});

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _savedCtrl = TextEditingController();
  String _emoji = '🎯';
  String _category = 'General';
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  Uint8List? _imageData; // base64 decoded bytes for preview

  final ImagePicker _picker = ImagePicker();
  final List<String> _categories = [
    'General',
    'Electronics',
    'Travel',
    'Education',
    'Emergency',
    'Lifestyle',
    'Investment'
  ];

  final List<String> _emojis = [
    '🎯',
    '💻',
    '✈️',
    '📱',
    '🏠',
    '🚗',
    '🎓',
    '💍',
    '📚',
    '💪',
    '🏖️',
    '🎮'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final g = widget.existing!;
      _nameCtrl.text = g.name;
      _targetCtrl.text = g.targetAmount.toStringAsFixed(0);
      _savedCtrl.text = g.savedAmount.toStringAsFixed(0);
      _emoji = g.emoji;
      _category = g.category;
      _targetDate = g.targetDate;
      if (g.imageData != null) {
        _imageData = base64Decode(g.imageData!);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _savedCtrl.dispose();
    super.dispose();
  }

  int get _monthsLeft {
    final now = DateTime.now();
    return (((_targetDate.year - now.year) * 12) +
            (_targetDate.month - now.month))
        .clamp(0, 999);
  }

  int get _daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay =
        DateTime(_targetDate.year, _targetDate.month, _targetDate.day);
    if (targetDay.isBefore(today)) return 0;
    return targetDay.difference(today).inDays;
  }

  double get _dailyNeeded {
    final target = double.tryParse(_targetCtrl.text) ?? 0;
    final saved = double.tryParse(_savedCtrl.text) ?? 0;
    final remaining = (target - saved).clamp(0.0, double.infinity);
    final days = _daysLeft;
    if (days <= 0) return 0;
    return remaining / days;
  }

  double get _weeklyNeeded {
    final days = _daysLeft;
    if (days <= 0) return _dailyNeeded * 7;
    return _dailyNeeded * 7;
  }

  double get _monthlyNeeded {
    final target = double.tryParse(_targetCtrl.text) ?? 0;
    final saved = double.tryParse(_savedCtrl.text) ?? 0;
    final remaining = (target - saved).clamp(0.0, double.infinity);
    final months = _monthsLeft;
    if (months <= 0) return remaining;
    return remaining / months;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final image = img_lib.decodeImage(bytes);
        if (image != null) {
          // Resize to thumbnail
          final thumb = img_lib.copyResize(image, width: 200, height: 200);
          final jpeg = img_lib.encodeJpg(thumb, quality: 85);
          setState(() {
            _imageData = Uint8List.fromList(jpeg);
          });
        }
      }
    } catch (e) {
      // Handle error silently or show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  String? get _imageDataBase64 =>
      _imageData != null ? base64Encode(_imageData!) : null;

  void _setPresetYears(int years) {
    setState(() {
      _targetDate = DateTime.now().add(Duration(days: years * 365));
    });
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty || _targetCtrl.text.isEmpty) return;

    final isEdit = widget.existing != null;
    final goal = Goal(
      id: isEdit ? widget.existing!.id : widget.state.newGoalId(),
      name: _nameCtrl.text.trim(),
      emoji: _emoji,
      targetAmount: double.tryParse(_targetCtrl.text) ?? 0,
      savedAmount: double.tryParse(_savedCtrl.text) ?? 0,
      startDate: isEdit ? widget.existing!.startDate : DateTime.now(),
      targetDate: _targetDate,
      category: _category,
      imageData: _imageDataBase64, // New
    );

    if (isEdit) {
      widget.state.updateGoal(goal);
    } else {
      widget.state.addGoal(goal);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_PH');
    final isEdit = widget.existing != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
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
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'Edit Goal' : 'New Goal',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageData != null
                        ? AppTheme.primary
                        : AppTheme.divider,
                    width: _imageData != null ? 2 : 1,
                  ),
                ),
                child: _imageData != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          _imageData!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              size: 40, color: AppTheme.textSecondary),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 14),
            // Emoji picker (smaller now)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _emojis.map((e) {
                  return GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _emoji == e
                            ? AppTheme.primary.withOpacity(0.12)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _emoji == e
                                ? AppTheme.primary
                                : Colors.transparent,
                            width: 2),
                      ),
                      child: Center(
                          child: Text(e, style: const TextStyle(fontSize: 16))),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Target Amount', prefixText: '₱ '),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _savedCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Already Saved', prefixText: '₱ '),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            // Target date picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: AppTheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Target Deadline',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                        Text(
                          DateFormat('MMMM d, yyyy').format(_targetDate),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${_daysLeft}d ($_monthsLeft mo)',
                      style: const TextStyle(
                          color: AppTheme.primary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            // Preset buttons
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _setPresetYears(1),
                    icon: const Icon(Icons.schedule_rounded, size: 16),
                    label: const Text('1 Year'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _setPresetYears(2),
                    icon: const Icon(Icons.schedule_rounded, size: 16),
                    label: const Text('2 Years'),
                  ),
                ),
              ],
            ),
            // Targets preview
            if (_targetCtrl.text.isNotEmpty && (_dailyNeeded > 0))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    // Monthly
                    if (_monthlyNeeded > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded,
                                  color: AppTheme.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Monthly: ₱${fmt.format(_monthlyNeeded)} needed',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Daily/Weekly
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up_rounded,
                              color: AppTheme.success, size: 18),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily: ₱${fmt.format(_dailyNeeded)}',
                                style: TextStyle(
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                              ),
                              Text(
                                'Weekly: ₱${fmt.format(_weeklyNeeded)}',
                                style: TextStyle(
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(isEdit ? 'Save Changes' : 'Create Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
