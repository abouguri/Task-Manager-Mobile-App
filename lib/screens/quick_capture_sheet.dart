import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/natural_language_schedule.dart';

class QuickCaptureSheet extends StatefulWidget {
  const QuickCaptureSheet({super.key, this.initialWhen = TaskWhen.inbox});

  final TaskWhen initialWhen;

  @override
  State<QuickCaptureSheet> createState() => _QuickCaptureSheetState();
}

class _QuickCaptureSheetState extends State<QuickCaptureSheet> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _tagController = TextEditingController();
  final _checklistController = TextEditingController();
  final List<ChecklistItem> _checklist = [];
  final List<String> _tags = [];
  DateTime? _date;
  TaskWhen _when = TaskWhen.inbox;

  @override
  void initState() {
    super.initState();
    _when = widget.initialWhen;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _tagController.dispose();
    _checklistController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final parsed = NaturalLanguageSchedule.parse(_title.text.trim());
    final value = parsed.title.isEmpty ? _title.text.trim() : parsed.title;
    if (value.isEmpty) return;
    final task = Task(
      title: value,
      description: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      checklist: _checklist,
      tags: _tags,
      when: _when == TaskWhen.inbox ? parsed.when : _when,
      scheduledFor: _when == TaskWhen.date ? (_date ?? parsed.date) : null,
      recurrence: _when == TaskWhen.inbox ? parsed.recurrence : null,
    );
    await context.read<TaskProvider>().addTask(task);
    if (mounted) Navigator.pop(context);
  }

  void _addChecklistItem() {
    final value = _checklistController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _checklist.add(ChecklistItem(title: value));
      _checklistController.clear();
    });
  }

  void _addTag() {
    final value = _tagController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _tags.add(value.startsWith('#') ? value.substring(1) : value);
      _tagController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: MediaQuery.sizeOf(context).width >= 900 ? 0.55 : 0.96,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).dividerColor, width: 1.4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _title,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'What needs doing?',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _notes,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Notes',
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_checklist.isNotEmpty)
                      SizedBox(
                        height: 130,
                        child: ReorderableListView.builder(
                          shrinkWrap: true,
                          buildDefaultDragHandles: false,
                          itemCount: _checklist.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final item = _checklist.removeAt(oldIndex);
                              _checklist.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            final item = _checklist[index];
                            return ListTile(
                              key: ValueKey('${item.title}-$index'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(item.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked, size: 18),
                              title: Text(item.title),
                              trailing: ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle_rounded),
                              ),
                            );
                          },
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _checklistController,
                            onSubmitted: (_) => _addChecklistItem(),
                            decoration: const InputDecoration(
                              hintText: 'Add checklist item',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addChecklistItem,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in _tags)
                            InputChip(
                              label: Text(tag),
                              onDeleted: () => setState(() => _tags.remove(tag)),
                            ),
                        ],
                      ),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            onSubmitted: (_) => _addTag(),
                            decoration: const InputDecoration(
                              hintText: 'Tag',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addTag,
                          icon: const Icon(Icons.tag_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Set date',
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 730)),
                              initialDate: _date ?? DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _date = picked;
                                _when = TaskWhen.date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                        ),
                        IconButton(
                          tooltip: 'Toggle flag',
                          onPressed: () => setState(() {
                            _when = _when == TaskWhen.today ? TaskWhen.inbox : TaskWhen.today;
                          }),
                          icon: Icon(
                            Icons.flag_rounded,
                            color: _when == TaskWhen.today ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<TaskWhen>(
                          tooltip: 'Destination',
                          initialValue: _when,
                          onSelected: (value) => setState(() => _when = value),
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: TaskWhen.inbox, child: Text('Inbox')),
                            PopupMenuItem(value: TaskWhen.today, child: Text('Today')),
                            PopupMenuItem(value: TaskWhen.evening, child: Text('This Evening')),
                            PopupMenuItem(value: TaskWhen.date, child: Text('Upcoming')),
                            PopupMenuItem(value: TaskWhen.anytime, child: Text('Anytime')),
                            PopupMenuItem(value: TaskWhen.someday, child: Text('Someday')),
                          ],
                          child: Row(
                            children: [
                              const Icon(Icons.inbox_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(_labelForWhen(_when)),
                              const Icon(Icons.keyboard_arrow_down_rounded),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(shape: const StadiumBorder()),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _labelForWhen(TaskWhen when) {
    switch (when) {
      case TaskWhen.inbox:
        return 'Inbox';
      case TaskWhen.today:
        return 'Today';
      case TaskWhen.evening:
        return 'Evening';
      case TaskWhen.date:
        return 'Upcoming';
      case TaskWhen.anytime:
        return 'Anytime';
      case TaskWhen.someday:
        return 'Someday';
    }
  }
}