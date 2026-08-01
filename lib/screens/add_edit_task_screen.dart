import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/natural_language_schedule.dart';

/// A quiet capture sheet: write first, decide where it belongs second.
class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});
  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _checklistItem = TextEditingController();
  TaskWhen _when = TaskWhen.inbox;
  DateTime? _date;
  List<ChecklistItem> _checklist = [];
  int? _selectedAreaId;
  int? _selectedProjectId;
  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task != null) {
      _title.text = task.title;
      _notes.text = task.description ?? '';
      _when = task.when;
      _date = task.scheduledFor;
      _checklist = List.of(task.checklist);
      _selectedAreaId = int.tryParse(task.areaId ?? '');
      _selectedProjectId = int.tryParse(task.projectId ?? '');
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _checklistItem.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final parsed = NaturalLanguageSchedule.parse(_title.text);
    final value = parsed.title;
    if (value.isEmpty) return;
    final task = Task(
        id: widget.task?.id,
        title: value,
        description: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        checklist: _checklist,
        when: _when == TaskWhen.inbox ? parsed.when : _when,
        scheduledFor: _date ?? parsed.date,
        projectId: _selectedProjectId?.toString(),
        areaId: _selectedAreaId?.toString(),
        recurrence: widget.task?.recurrence ?? parsed.recurrence,
        isCompleted: widget.task?.isCompleted ?? false,
        completedAt: widget.task?.completedAt,
        createdAt: widget.task?.createdAt);
    final tasks = context.read<TaskProvider>();
    if (widget.task == null) {
      await tasks.addTask(task);
    } else {
      await tasks.updateTask(task);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        
        appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context)),
            actions: [TextButton(onPressed: _save, child: const Text('Done'))]),
      body: Consumer<TaskProvider>(
        builder: (context, tasks, child) {
        final availableProjects = _selectedAreaId == null
          ? tasks.projects
          : tasks.projects
            .where((project) =>
              project.areaId == _selectedAreaId || project.areaId == null)
            .toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  widget.task == null
                      ? 'What needs your attention?'
                      : 'Edit task',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              TextField(
                  controller: _title,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context).textTheme.titleLarge,
                  decoration: const InputDecoration(
                      hintText: 'Write a task…',
                      border: InputBorder.none,
                      filled: false)),
              TextField(
                  controller: _notes,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      hintText: 'Add a note',
                      border: InputBorder.none,
                      filled: false)),
              const Spacer(),
              if (_checklist.isNotEmpty) ...[
                const Divider(),
                for (var i = 0; i < _checklist.length; i++)
                  Row(children: [
                    Checkbox(
                        value: _checklist[i].isCompleted,
                        onChanged: (value) => setState(() => _checklist[i] =
                            _checklist[i].copyWith(isCompleted: value))),
                    Expanded(
                        child: Text(_checklist[i].title,
                            style: TextStyle(
                                decoration: _checklist[i].isCompleted
                                    ? TextDecoration.lineThrough
                                    : null))),
                    IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _checklist.removeAt(i)))
                  ]),
              ],
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _checklistItem,
                        onSubmitted: (_) => _addChecklistItem(),
                        decoration: const InputDecoration(
                            hintText: 'Add a checklist item',
                            border: InputBorder.none,
                            filled: false))),
                IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add checklist item',
                    onPressed: _addChecklistItem)
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: _selectedAreaId,
                decoration: const InputDecoration(
                  labelText: 'Area (optional)',
                  prefixIcon: Icon(Icons.circle_outlined, size: 18),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('No area'),
                  ),
                  ...tasks.areas.map(
                    (area) => DropdownMenuItem<int?>(
                      value: area.id,
                      child: Text(area.title),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAreaId = value;
                    final selectedProject = tasks.projectById(_selectedProjectId);
                    if (selectedProject != null &&
                        selectedProject.areaId != null &&
                        selectedProject.areaId != _selectedAreaId) {
                      _selectedProjectId = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: _selectedProjectId,
                decoration: const InputDecoration(
                  labelText: 'Project (optional)',
                  prefixIcon: Icon(Icons.folder_outlined, size: 18),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('No project'),
                  ),
                  ...availableProjects.map(
                    (project) => DropdownMenuItem<int?>(
                      value: project.id,
                      child: Text(
                        project.areaId == null
                            ? project.title
                            : '${tasks.areaById(project.areaId)?.title ?? 'Area'} • ${project.title}',
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                    final selectedProject = tasks.projectById(value);
                    if (selectedProject != null) {
                      _selectedAreaId = selectedProject.areaId ?? _selectedAreaId;
                    }
                  });
                },
              ),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _whenChip(TaskWhen.inbox, 'Inbox'),
                _whenChip(TaskWhen.today, 'Today'),
                _whenChip(TaskWhen.evening, 'This evening'),
                _whenChip(TaskWhen.someday, 'Someday'),
                ActionChip(
                    label: Text(_date == null
                        ? 'Pick a date'
                        : '${_date!.month}/${_date!.day}'),
                    avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                    onPressed: () async {
                      final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 730)),
                          initialDate: _date ?? DateTime.now());
                      if (picked != null)
                        setState(() {
                          _date = picked;
                          _when = TaskWhen.date;
                        });
                    }),
              ]),
              const SizedBox(height: 16),
            ]));
          },
        ),
      );
  void _addChecklistItem() {
    final value = _checklistItem.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _checklist.add(ChecklistItem(title: value));
      _checklistItem.clear();
    });
  }

  Widget _whenChip(TaskWhen when, String label) => ChoiceChip(
      label: Text(label),
      selected: _when == when,
      onSelected: (_) => setState(() {
            _when = when;
            if (when != TaskWhen.date) _date = null;
          }));
}
