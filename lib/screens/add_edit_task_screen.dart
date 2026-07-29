import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../design/taskflow_tokens.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

/// Screen for adding a new task or editing an existing task
class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _showMoreDetails = false;
  
  String _priority = 'Medium';
  String _category = 'Personal';
  String _energyLevel = 'Flexible';
  int _effortMinutes = 15;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing task data
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _tagsController.text = widget.task!.tags.join(', ');
      _priority = widget.task!.priority;
      _category = widget.task!.category;
      _energyLevel = widget.task!.energyLevel;
      _effortMinutes = widget.task!.effortMinutes;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// Show date picker dialog
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  /// Save or update task
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final task = Task(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priority: _priority,
        category: _category,
        tags: _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
        effortMinutes: _effortMinutes,
        energyLevel: _energyLevel,
        dueDate: _dueDate,
        isCompleted: widget.task?.isCompleted ?? false,
        createdAt: widget.task?.createdAt,
      );

      final taskProvider = context.read<TaskProvider>();

      if (widget.task == null) {
        // Adding new task
        await taskProvider.addTask(task);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Updating existing task
        await taskProvider.updateTask(task);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully!'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            Text(
              'Capture first, refine later.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'What needs to be done?',
                prefixIcon: Icon(Icons.edit_outlined),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional details',
                prefixIcon: Icon(Icons.notes_outlined),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                setState(() {
                  _showMoreDetails = !_showMoreDetails;
                });
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(_showMoreDetails ? 'Hide details' : 'More details'),
              ),
            ),

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      prefixIcon: Icon(Icons.flag_outlined),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    items: ['Low', 'Medium', 'High'].map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _priority = value ?? 'Medium';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Project',
                      prefixIcon: Icon(Icons.folder_outlined),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    items: ['Work', 'Personal', 'Shopping', 'Health', 'Other']
                        .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value ?? 'Personal';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'home, finance, urgent',
                      prefixIcon: Icon(Icons.sell_outlined),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _effortMinutes,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      prefixIcon: Icon(Icons.timelapse_rounded),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    items: const [
                      DropdownMenuItem(value: 15, child: Text('15 min')),
                      DropdownMenuItem(value: 30, child: Text('30 min')),
                      DropdownMenuItem(value: 60, child: Text('1 hour')),
                      DropdownMenuItem(value: 120, child: Text('2 hours')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _effortMinutes = value ?? 15;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _energyLevel,
                    decoration: const InputDecoration(
                      labelText: 'Energy',
                      prefixIcon: Icon(Icons.bolt_outlined),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Deep Work', child: Text('Deep Work')),
                      DropdownMenuItem(value: 'Quick Win', child: Text('Quick Win')),
                      DropdownMenuItem(value: 'Flexible', child: Text('Flexible')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _energyLevel = value ?? 'Flexible';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(TaskFlowTokens.radiusMd),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        hintText: 'Optional',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      child: Text(
                        _dueDate != null
                            ? DateFormat('EEE, MMM d').format(_dueDate!)
                            : 'No due date',
                        style: TextStyle(
                          color: _dueDate != null ? null : Theme.of(context).colorScheme.outline,
                          fontWeight: _dueDate != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  if (_dueDate != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                          });
                        },
                        child: const Text('Clear due date'),
                      ),
                    ),
                  ],
                ],
              ),
              crossFadeState: _showMoreDetails ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing ? Icons.check_rounded : Icons.add_rounded,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? 'Update Task' : 'Add Task',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
