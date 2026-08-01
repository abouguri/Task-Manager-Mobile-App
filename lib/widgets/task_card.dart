import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../design/taskflow_tokens.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/add_edit_task_screen.dart';

/// Reusable widget for displaying a task in an expandable card format
class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final provider = context.read<TaskProvider>();
    final area = provider.areaById(int.tryParse(widget.task.areaId ?? ''));
    final project = provider.projectById(int.tryParse(widget.task.projectId ?? ''));
    final organizationLabel = project?.title ?? area?.title ?? widget.task.category;
    
    return Dismissible(
      key: Key(widget.task.id.toString()),
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: const Color(0xFF51CF66),
        icon: Icons.check_circle_rounded,
        label: 'Complete',
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: const Color(0xFFFF6B6B),
        icon: Icons.delete_rounded,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - Complete task
          context.read<TaskProvider>().toggleTaskCompletion(widget.task);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.task.isCompleted ? 'Task marked incomplete' : 'Task completed!'),
              backgroundColor: const Color(0xFF51CF66),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          return false; // Don't remove from list
        } else {
          // Swipe left - Delete task
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Task'),
              content: Text('Are you sure you want to delete "${widget.task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ) ?? false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          context.read<TaskProvider>().deleteTask(widget.task.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted'),
              backgroundColor: Color(0xFFFF6B6B),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(TaskFlowTokens.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Checkbox with animation
                  GestureDetector(
                    onTap: () {
                      context.read<TaskProvider>().toggleTaskCompletion(widget.task);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.task.isCompleted
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.task.isCompleted
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                          width: 1.6,
                        ),
                      ),
                      child: widget.task.isCompleted
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
                            // Title
                            Expanded(
                              child: Text(
                                widget.task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: widget.task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: widget.task.isCompleted
                                      ? theme.colorScheme.outline
                                      : isDark ? Colors.white : const Color(0xFF1B1B1D),
                                  letterSpacing: -0.3,
                                ),
                                maxLines: _isExpanded ? null : 2,
                                overflow: _isExpanded ? null : TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Category and Due Date - Minimalist badges
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // Category badge
                            _buildMinimalBadge(
                              icon: _getCategoryIcon(organizationLabel),
                              label: organizationLabel,
                              isDark: isDark,
                            ),

                            // Due date badge
                            if (widget.task.dueDate != null)
                              _buildMinimalBadge(
                                icon: Icons.calendar_today_rounded,
                                label: _formatDueDate(widget.task.dueDate!),
                                isDark: isDark,
                              ),

                            _buildMinimalBadge(
                              icon: Icons.timer_rounded,
                              label: '${widget.task.effortMinutes} min',
                              isDark: isDark,
                            ),

                            _buildMinimalBadge(
                              icon: Icons.bolt_rounded,
                              label: widget.task.energyLevel,
                              isDark: isDark,
                            ),
                          ],
                        ),
                        if (widget.task.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: widget.task.tags
                                .map(
                                  (tag) => Chip(
                                    label: Text(tag),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Expand icon
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.withOpacity(0.5),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 24),
                  
                  // Description
                  if (widget.task.description != null && widget.task.description!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.notes_outlined, size: 18, color: theme.colorScheme.outline),
                        const SizedBox(width: 8),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.outline,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[300] : const Color(0xFF46423D),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Priority
                  Row(
                    children: [
                      Icon(Icons.flag_outlined, size: 18, color: theme.colorScheme.outline),
                      const SizedBox(width: 8),
                      Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.outline,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.task.priority,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Created date
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 18, color: theme.colorScheme.outline),
                      const SizedBox(width: 8),
                      Text(
                        'Created',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.outline,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(widget.task.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (widget.task.tags.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.sell_outlined, size: 18, color: theme.colorScheme.outline),
                        const SizedBox(width: 8),
                        Text(
                          'Tags',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.outline,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.task.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditTaskScreen(task: widget.task),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteConfirmation(context),
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    );
  }

  /// Build swipe action background
  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a minimal badge widget
  Widget _buildMinimalBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.outline,
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
        content: Text('Are you sure you want to delete "${widget.task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<TaskProvider>().deleteTask(widget.task.id!);
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
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return const Color(0xFF2F5B52);
      case 'Personal':
        return const Color(0xFF7E6A58);
      case 'Shopping':
        return const Color(0xFF5D736E);
      case 'Health':
        return const Color(0xFF8A6B54);
      case 'Other':
        return const Color(0xFF7C756B);
      default:
        return const Color(0xFF7C756B);
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
    return const Color(0xFF7C756B);
  }
}
