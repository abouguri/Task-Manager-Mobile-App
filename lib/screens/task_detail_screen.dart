import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';

/// Screen to display detailed information about a task
class TaskDetailScreen extends StatelessWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final task = context.read<TaskProvider>().getTaskById(taskId);
              if (task != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTaskScreen(task: task),
                  ),
                );
              }
            },
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final task = taskProvider.getTaskById(taskId);

          if (task == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Task not found',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completion status card
                Card(
                  color: task.isCompleted ? Colors.green[50] : Colors.blue[50],
                  child: ListTile(
                    leading: Icon(
                      task.isCompleted ? Icons.check_circle : Icons.pending,
                      color: task.isCompleted ? Colors.green : Colors.blue,
                      size: 32,
                    ),
                    title: Text(
                      task.isCompleted ? 'Completed' : 'Pending',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Switch(
                      value: task.isCompleted,
                      onChanged: (value) {
                        taskProvider.toggleTaskCompletion(task);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Task marked as completed!'
                                  : 'Task marked as pending!',
                            ),
                            backgroundColor: value ? Colors.green : Colors.blue,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                _buildSectionTitle('Title'),
                _buildInfoCard(
                  icon: Icons.title,
                  content: task.title,
                ),
                const SizedBox(height: 16),

                // Description
                if (task.description != null && task.description!.isNotEmpty) ...[
                  _buildSectionTitle('Description'),
                  _buildInfoCard(
                    icon: Icons.description,
                    content: task.description!,
                  ),
                  const SizedBox(height: 16),
                ],

                // Priority
                _buildSectionTitle('Priority'),
                _buildInfoCard(
                  icon: Icons.flag,
                  content: task.priority,
                  color: _getPriorityColor(task.priority),
                ),
                const SizedBox(height: 16),

                // Category
                _buildSectionTitle('Category'),
                _buildInfoCard(
                  icon: _getCategoryIcon(task.category),
                  content: task.category,
                  color: _getCategoryColor(task.category),
                ),
                const SizedBox(height: 16),

                // Due Date
                _buildSectionTitle('Due Date'),
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  content: task.dueDate != null
                      ? DateFormat('EEEE, MMMM dd, yyyy').format(task.dueDate!)
                      : 'No due date set',
                  color: task.dueDate != null
                      ? _getDueDateColor(task.dueDate!)
                      : Colors.grey,
                ),
                const SizedBox(height: 16),

                // Created At
                _buildSectionTitle('Created'),
                _buildInfoCard(
                  icon: Icons.access_time,
                  content: DateFormat('EEEE, MMMM dd, yyyy - hh:mm a')
                      .format(task.createdAt),
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditTaskScreen(task: task),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Task'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Task'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Build info card
  Widget _buildInfoCard({
    required IconData icon,
    required String content,
    Color? color,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    final task = context.read<TaskProvider>().getTaskById(taskId);
    if (task == null) return;

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
              Navigator.pop(context); // Close dialog
              try {
                await context.read<TaskProvider>().deleteTask(task.id!);
                if (context.mounted) {
                  Navigator.pop(context); // Go back to home screen
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
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get color based on category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Personal':
        return Colors.purple;
      case 'Shopping':
        return Colors.teal;
      case 'Health':
        return Colors.pink;
      case 'Other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get icon based on category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Personal':
        return Icons.person;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Health':
        return Icons.favorite;
      case 'Other':
        return Icons.category;
      default:
        return Icons.category;
    }
  }

  /// Get color based on due date
  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate.isBefore(today)) {
      return Colors.red; // Overdue
    } else if (taskDate == today) {
      return Colors.orange; // Due today
    } else {
      return Colors.blue; // Future date
    }
  }
}
