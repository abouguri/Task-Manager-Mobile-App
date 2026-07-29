import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../design/taskflow_tokens.dart';
import '../providers/task_provider.dart';

/// Widget displaying task completion statistics
class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key});

  static const int _xpPerCompletedTask = 20;

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    
    final allTasks = taskProvider.tasks;
    final completedTasks = allTasks.where((task) => task.isCompleted).length;
    final totalTasks = allTasks.length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).toInt() : 0;
    final xp = completedTasks * _xpPerCompletedTask;
    final level = (xp / 100).floor() + 1;
    final levelProgress = (xp % 100) / 100;
    
    // Tasks completed today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedToday = allTasks.where((task) {
      if (!task.isCompleted) return false;
      // Use createdAt as a proxy - in a real app you'd have updatedAt
      final completedAt = task.completedAt ?? task.createdAt;
      final taskDate = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );
      return taskDate == today;
    }).length;

    final completionDates = allTasks
        .where((task) => task.isCompleted)
        .map((task) => DateTime(
              (task.completedAt ?? task.createdAt).year,
              (task.completedAt ?? task.createdAt).month,
              (task.completedAt ?? task.createdAt).day,
            ))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final streak = _calculateStreak(completionDates);
    
    // Tasks due today
    final dueToday = allTasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return dueDate == today && !task.isCompleted;
    }).length;

    final weeklyCompletionCounts = List<int>.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      return allTasks.where((task) {
        if (!task.isCompleted || task.completedAt == null) return false;
        final completedDate = DateTime(
          task.completedAt!.year,
          task.completedAt!.month,
          task.completedAt!.day,
        );
        return completedDate == day;
      }).length;
    });

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(TaskFlowTokens.radiusLg),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: TaskFlowTokens.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Your Progress',
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gamification header
          Row(
            children: [
              Expanded(
                child: _buildLevelCard(
                  level: level,
                  xp: xp,
                  progress: levelProgress,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStreakCard(streak: streak),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed Today',
                  value: completedToday.toString(),
                      context: context,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.event_rounded,
                  label: 'Due Today',
                  value: dueToday.toString(),
                      context: context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly completion trend
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completion Trend',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weeklyCompletionCounts.asMap().entries.map((entry) {
                  final value = entry.value;
                  final height = value == 0 ? 8.0 : 18.0 + (value * 10.0);
                  final isTodayColumn = entry.key == 6;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: isTodayColumn
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _weekdayLabel(dayIndex: entry.key),
                            style: TextStyle(
                              color: theme.colorScheme.outline,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Challenge strip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(TaskFlowTokens.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: TaskFlowTokens.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    streak >= 3
                        ? 'Daily challenge unlocked: keep your streak alive.'
                        : 'Daily challenge: complete 3 tasks today for a bonus.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Completion Rate Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Completion Rate',
                    style: TextStyle(
                      color: TaskFlowTokens.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$completionRate%',
                    style: const TextStyle(
                      color: TaskFlowTokens.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: completionRate / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation<Color>(TaskFlowTokens.primary),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$completedTasks of $totalTasks tasks completed',
                style: TextStyle(
                  color: theme.colorScheme.outline,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.65),
        borderRadius: BorderRadius.circular(TaskFlowTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TaskFlowTokens.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: TaskFlowTokens.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required int level,
    required int xp,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            'Level $level',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$xp XP',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard({required int streak}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            '$streak day streak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            streak > 0 ? 'Keep the momentum going' : 'Complete a task to start one',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStreak(List<DateTime> sortedCompletionDates) {
    if (sortedCompletionDates.isEmpty) {
      return 0;
    }

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    var streak = 0;
    var cursor = normalizedToday;

    for (final date in sortedCompletionDates) {
      if (date == cursor) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (date.isBefore(cursor)) {
        continue;
      } else {
        break;
      }
    }

    return streak;
  }

  String _weekdayLabel({required int dayIndex}) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[(dayIndex + 1) % 7];
  }
}
