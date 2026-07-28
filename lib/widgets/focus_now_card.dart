import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFF6C63FF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Best next tasks based on urgency and effort',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.04)
                        : const Color(0xFFF7F7FB),
                    borderRadius: BorderRadius.circular(18),
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
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
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
          ? const Color(0xFFFF6B6B)
          : score >= 50
              ? const Color(0xFFFFB020)
              : const Color(0xFF6C63FF);
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