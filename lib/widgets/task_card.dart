import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

/// Reusable widget for displaying a task in a card format
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Checkbox with animation
              GestureDetector(
                onTap: () {
                  context.read<TaskProvider>().toggleTaskCompletion(task);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? _getPriorityColor(task.priority)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: task.isCompleted
                          ? _getPriorityColor(task.priority)
                          : Colors.grey.withOpacity(0.3),
                      width: 2.5,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with priority dot
                    Row(
                      children: [
                        // Priority dot indicator
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(task.priority),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getPriorityColor(task.priority).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? Colors.grey.withOpacity(0.6)
                                  : isDark ? Colors.white : const Color(0xFF1A1A1A),
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Description (if available)
                    if (task.description != null && task.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: task.isCompleted
                                ? Colors.grey.withOpacity(0.5)
                                : Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Category and Due Date - Minimalist badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Category badge
                        _buildMinimalBadge(
                          icon: _getCategoryIcon(task.category),
                          label: task.category,
                          color: _getCategoryColor(task.category),
                          isDark: isDark,
                        ),

                        // Due date badge
                        if (task.dueDate != null)
                          _buildMinimalBadge(
                            icon: Icons.calendar_today_rounded,
                            label: _formatDueDate(task.dueDate!),
                            color: _getDueDateColor(task.dueDate!),
                            isDark: isDark,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button - Minimalist icon
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.grey.withOpacity(0.5),
                ),
                iconSize: 22,
                onPressed: () => _showDeleteConfirmation(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a minimal badge widget
  Widget _buildMinimalBadge({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<TaskProvider>().deleteTask(task.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Get color based on priority
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFFF6B6B); // Modern coral red
      case 'Medium':
        return const Color(0xFFFFA94D); // Warm orange
      case 'Low':
        return const Color(0xFF51CF66); // Fresh green
      default:
        return const Color(0xFF94A3B8); // Soft grey
    }
  }

  /// Get color based on category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return const Color(0xFF6C63FF); // Modern purple
      case 'Personal':
        return const Color(0xFFFF6584); // Pink accent
      case 'Shopping':
        return const Color(0xFF20C997); // Teal
      case 'Health':
        return const Color(0xFFFF8787); // Soft red
      case 'Other':
        return const Color(0xFF94A3B8); // Neutral grey
      default:
        return const Color(0xFF94A3B8);
    }
  }

  /// Get icon based on category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work_outline_rounded;
      case 'Personal':
        return Icons.person_outline_rounded;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Health':
        return Icons.favorite_border_rounded;
      case 'Other':
        return Icons.label_outline_rounded;
      default:
        return Icons.label_outline_rounded;
    }
  }

  /// Format due date
  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else if (taskDate.isBefore(today)) {
      return 'Overdue';
    } else {
      return DateFormat('MMM dd').format(dueDate);
    }
  }

  /// Get color based on due date
  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate.isBefore(today)) {
      return const Color(0xFFFF6B6B); // Overdue - coral red
    } else if (taskDate == today) {
      return const Color(0xFFFFA94D); // Due today - warm orange
    } else {
      return const Color(0xFF748FFC); // Future date - soft blue
    }
  }
}
