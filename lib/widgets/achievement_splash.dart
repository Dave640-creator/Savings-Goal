import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../core/app_theme.dart';
import '../models/goal_model.dart';

void showAchievementSplash(BuildContext context, Goal goal) {
  final daysTaken = DateTime.now().difference(goal.startDate).inDays;
  final monthsTaken = ((DateTime.now().year - goal.startDate.year) * 12) +
      (DateTime.now().month - goal.startDate.month);
  final timeTaken = daysTaken > 30 ? '$monthsTaken months' : '$daysTaken days';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _AchievementSplash(goal: goal, timeTaken: timeTaken),
  );
}

class _AchievementSplash extends StatefulWidget {
  final Goal goal;
  final String timeTaken;

  const _AchievementSplash({required this.goal, required this.timeTaken});

  @override
  State<_AchievementSplash> createState() => _AchievementSplashState();
}

class _AchievementSplashState extends State<_AchievementSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_PH');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary.withOpacity(0.9),
              AppTheme.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Celebration icon
                      const Text(
                        '🎉',
                        style: TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 24),
                      // Congratulatory message
                      const Text(
                        'Congratulations!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You did it!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Goal image/emoji
                      if (widget.goal.imageData != null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              MemoryImage(base64Decode(widget.goal.imageData!)),
                          backgroundColor: Colors.white.withOpacity(0.2),
                        )
                      else
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            widget.goal.emoji,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Goal name
                      Text(
                        widget.goal.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Target amount
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '₱${fmt.format(widget.goal.targetAmount)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Stats card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            _StatRow(
                              icon: Icons.calendar_today,
                              label: 'Started',
                              value: DateFormat('MMM d, yyyy')
                                  .format(widget.goal.startDate),
                            ),
                            const SizedBox(height: 12),
                            _StatRow(
                              icon: Icons.celebration,
                              label: 'Completed',
                              value: DateFormat('MMM d, yyyy')
                                  .format(DateTime.now()),
                            ),
                            const SizedBox(height: 12),
                            _StatRow(
                              icon: Icons.timer,
                              label: 'Time Taken',
                              value: widget.timeTaken,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Motivational message
                      const Text(
                        'Your dedication and consistency paid off! Keep up the great work and continue building your savings habits.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Dismiss button
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white60,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
