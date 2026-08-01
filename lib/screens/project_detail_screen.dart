import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/organization.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final List<String> _headings = ['General'];
  final Map<String, List<Task>> _tasksByHeading = {'General': []};
  final TextEditingController _headingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTasks();
  }

  @override
  void dispose() {
    _headingController.dispose();
    super.dispose();
  }

  void _syncTasks() {
    final provider = context.read<TaskProvider>();
    final tasks = provider.allTasks.where((task) => int.tryParse(task.projectId ?? '') == widget.project.id && !task.isCompleted).toList();
    _tasksByHeading['General'] = tasks;
  }

  Future<void> _addTaskToProject([String heading = 'General']) async {
    final project = widget.project;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(
          task: Task(title: '', projectId: project.id?.toString(), areaId: project.areaId?.toString()),
        ),
      ),
    );
    if (mounted) setState(_syncTasks);
  }

  Future<void> _addHeading() async {
    final value = _headingController.text.trim();
    if (value.isEmpty || _headings.contains(value)) return;
    setState(() {
      _headings.add(value);
      _tasksByHeading[value] = <Task>[];
      _headingController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final area = provider.areaById(widget.project.areaId);
    final color = area != null ? Color(area.accentColor) : Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 10, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: color.withOpacity(0.16), shape: BoxShape.circle),
                    child: Icon(Icons.folder_rounded, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.project.title, style: Theme.of(context).textTheme.displayMedium),
                        if (area != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(area.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.project.isCompleted)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Completed project', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  for (final heading in _headings) ...[
                    _ProjectHeading(
                      title: heading,
                      color: color,
                      onAddTask: () => _addTaskToProject(heading),
                      onOverflow: () {},
                      tasks: _tasksByHeading[heading] ?? const [],
                      onTaskDropped: (task) => setState(() {
                        for (final entry in _tasksByHeading.entries) {
                          entry.value.removeWhere((item) => item.id == task.id);
                        }
                        _tasksByHeading.putIfAbsent(heading, () => <Task>[]).add(task);
                      }),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextField(
                    controller: _headingController,
                    decoration: InputDecoration(
                      hintText: 'Add heading',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: _addHeading,
                      ),
                    ),
                    onSubmitted: (_) => _addHeading(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskToProject,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProjectHeading extends StatelessWidget {
  const _ProjectHeading({
    required this.title,
    required this.color,
    required this.onAddTask,
    required this.onOverflow,
    required this.tasks,
    required this.onTaskDropped,
  });

  final String title;
  final Color color;
  final VoidCallback onAddTask;
  final VoidCallback onOverflow;
  final List<Task> tasks;
  final ValueChanged<Task> onTaskDropped;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onAcceptWithDetails: (details) => onTaskDropped(details.data),
      builder: (context, candidate, rejected) {
        return Container(
          decoration: BoxDecoration(
            color: candidate.isNotEmpty ? color.withOpacity(0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: onAddTask,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded),
                    onPressed: onOverflow,
                  ),
                ],
              ),
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 8),
                  child: Text('Drop tasks here or add a new one.', style: Theme.of(context).textTheme.bodyMedium),
                )
              else
                for (final task in tasks) _ProjectTaskRow(task: task, color: color),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectTaskRow extends StatelessWidget {
  const _ProjectTaskRow({required this.task, required this.color});

  final Task task;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final project = provider.projectById(int.tryParse(task.projectId ?? ''));
    return LongPressDraggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(blurRadius: 18, color: Color(0x22000000), offset: Offset(0, 8))],
          ),
          child: Text(task.title),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.45,
        child: _taskRow(context, project),
      ),
      child: _taskRow(context, project),
    );
  }

  Widget _taskRow(BuildContext context, Project? project) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).dividerColor, width: 1.4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  if (project != null) Text(project.title, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (task.checklist.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text('${task.checklist.where((item) => item.isCompleted).length}/${task.checklist.length}', style: Theme.of(context).textTheme.labelMedium),
              ),
            if (task.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.sell_outlined, size: 16, color: color),
              ),
          ],
        ),
      ),
    );
  }
}