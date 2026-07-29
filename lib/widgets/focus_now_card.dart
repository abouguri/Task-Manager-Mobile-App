import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../design/taskflow_tokens.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';

/// Card that highlights the most actionable incomplete tasks right now.
class FocusNowCard extends StatelessWidget {
  const FocusNowCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final suggestions = _buildSuggestions(tasks);

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(TaskFlowTokens.radiusLg),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: TaskFlowTokens.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus Now',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                        const SizedBox(height: 2),
                    Text(
                      'Best next tasks based on urgency and effort',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...suggestions.map(
            (suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(taskId: suggestion.task.id!),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(TaskFlowTokens.radiusMd),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: suggestion.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion.task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              suggestion.reason,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_SuggestedTask> _buildSuggestions(List<Task> tasks) {
    final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
    if (incompleteTasks.isEmpty) {
      return const [];
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    incompleteTasks.sort((a, b) => _score(b, today).compareTo(_score(a, today)));

    return incompleteTasks.take(3).map((task) {
      final score = _score(task, today);
      final accent = score >= 80
          ? TaskFlowTokens.danger
          : score >= 50
            ? TaskFlowTokens.warning
            : TaskFlowTokens.primary;
      return _SuggestedTask(
        task: task,
        reason: _reasonFor(task, today),
        accent: accent,
      );
    }).toList();
  }

  int _score(Task task, DateTime today) {
    var score = 0;

    if (task.dueDate != null) {
      final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      final daysUntilDue = dueDate.difference(today).inDays;
      if (daysUntilDue < 0) {
        score += 90;
      } else if (daysUntilDue == 0) {
        score += 80;
      } else if (daysUntilDue == 1) {
        score += 60;
      } else if (daysUntilDue <= 3) {
        score += 40;
      }
    }

    switch (task.priority) {
      case 'High':
        score += 30;
        break;
      case 'Medium':
        score += 15;
        break;
      case 'Low':
        score += 5;
        break;
    }

    if (task.energyLevel == 'Quick Win' && task.effortMinutes <= 30) {
      score += 20;
    } else if (task.energyLevel == 'Deep Work' && task.effortMinutes >= 60) {
      score += 15;
    }

    if (task.effortMinutes <= 30) {
      score += 10;
    }

    return score;
  }

  String _reasonFor(Task task, DateTime today) {
    if (task.dueDate != null) {
      final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      final daysUntilDue = dueDate.difference(today).inDays;
      if (daysUntilDue < 0) {
        return 'Overdue and needs attention now';
      }
      if (daysUntilDue == 0) {
        return 'Due today, high priority';
      }
      if (daysUntilDue == 1) {
        return 'Due tomorrow';
      }
    }

    if (task.energyLevel == 'Quick Win' && task.effortMinutes <= 30) {
      return 'Fast win that fits a short break';
    }

    if (task.energyLevel == 'Deep Work' && task.effortMinutes >= 60) {
      return 'Best saved for a focus block';
    }

    return 'Good next task to move forward';
  }
}

class _SuggestedTask {
  _SuggestedTask({
    required this.task,
    required this.reason,
    required this.accent,
  });

  final Task task;
  final String reason;
  final Color accent;
}