import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../design/taskflow_tokens.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/natural_language_schedule.dart';
import '../widgets/tf_widgets.dart';

/// The full editor behind a task's "Edit" action.
///
/// It reads as the open card made editable: the same checkbox-and-title
/// header, the same 32px indent under it, and the design's blue-header-over-a-
/// hairline device used to group the fields the card only summarises.
class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  final Task? task;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _checklistItem = TextEditingController();
  final _tagItem = TextEditingController();

  List<ChecklistItem> _checklist = [];
  List<String> _tags = [];
  TaskWhen _when = TaskWhen.inbox;
  DateTime? _date;
  DateTime? _deadline;
  int? _areaId;
  int? _projectId;
  String? _heading;

  bool get _isNew => widget.task == null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task == null) return;
    _title.text = task.title;
    _notes.text = task.description ?? '';
    _checklist = List.of(task.checklist);
    _tags = List.of(task.tags);
    _when = task.when;
    _date = task.scheduledFor;
    _deadline = task.deadline;
    _areaId = int.tryParse(task.areaId ?? '');
    _projectId = int.tryParse(task.projectId ?? '');
    _heading = task.heading;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _checklistItem.dispose();
    _tagItem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<TaskProvider>();
    const indent = TaskFlowTokens.checkbox + 12;

    return Scaffold(
      backgroundColor: palette.surface,
      body: SafeArea(
        child: Column(
          children: [
            _EditorBar(
              onCancel: () => Navigator.pop(context),
              onDone: _save,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    TaskFlowTokens.gutter, 14, TaskFlowTokens.gutter, 48),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: TfCheckbox(checked: false),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BareField(
                          controller: _title,
                          hint: 'New To-Do',
                          autofocus: _isNew,
                          maxLines: 2,
                          style:
                              TaskFlowText.openTaskTitle(palette.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: indent, top: 10),
                    child: _BareField(
                      controller: _notes,
                      hint: 'Notes',
                      maxLines: 6,
                      style: TaskFlowText.notes(palette.textSecondary),
                    ),
                  ),
                  TfSectionHeader(title: 'Checklist'),
                  ..._checklistRows(palette),
                  TfSectionHeader(title: 'Tags'),
                  _tagsBlock(palette),
                  TfSectionHeader(title: 'When'),
                  _ValueRow(
                    icon: _whenIcon(_when),
                    label: _whenLabel(_when),
                    detail: _when == TaskWhen.date && _date != null
                        ? DateFormat('EEE, MMM d').format(_date!)
                        : null,
                    onTap: _pickWhen,
                  ),
                  TfSectionHeader(title: 'Deadline'),
                  _ValueRow(
                    icon: Icons.flag_outlined,
                    iconColor: _deadline == null ? null : palette.danger,
                    label: _deadline == null
                        ? 'No deadline'
                        : DateFormat('EEE, MMM d').format(_deadline!),
                    onTap: _pickDeadline,
                    onClear:
                        _deadline == null ? null : () => setState(() => _deadline = null),
                  ),
                  TfSectionHeader(title: 'Organize'),
                  _ValueRow(
                    icon: Icons.layers_outlined,
                    label: provider.areaById(_areaId)?.title ?? 'No area',
                    onTap: () => _pickArea(provider),
                  ),
                  _ValueRow(
                    icon: Icons.folder_outlined,
                    label:
                        provider.projectById(_projectId)?.title ?? 'No project',
                    onTap: () => _pickProject(provider),
                  ),
                  if ((provider.projectById(_projectId)?.headings ?? const [])
                      .isNotEmpty)
                    _ValueRow(
                      icon: Icons.segment_rounded,
                      label: _heading ?? 'No heading',
                      onTap: () => _pickHeading(provider),
                    ),
                  if (!_isNew)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _delete,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: palette.danger),
                            const SizedBox(width: 10),
                            Text('Delete to-do',
                                style: TaskFlowText.projectTitle(
                                    palette.danger)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Blocks -------------------------------------------------------------

  List<Widget> _checklistRows(TaskFlowPalette palette) {
    return [
      for (var i = 0; i < _checklist.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              TfChecklistMark(
                checked: _checklist[i].isCompleted,
                onTap: () => setState(() => _checklist[i] = _checklist[i]
                    .copyWith(isCompleted: !_checklist[i].isCompleted)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  _checklist[i].title,
                  style: TaskFlowText.checklistItem(palette.textPrimary)
                      .copyWith(
                    decoration: _checklist[i].isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: _checklist[i].isCompleted
                        ? palette.textTertiary
                        : palette.textPrimary,
                  ),
                ),
              ),
              TfGlyphButton(
                icon: Icons.close_rounded,
                size: 14,
                color: palette.textQuaternary,
                onTap: () => setState(() => _checklist.removeAt(i)),
              ),
            ],
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(Icons.add_rounded, size: 15, color: palette.accent),
            const SizedBox(width: 11),
            Expanded(
              child: _BareField(
                controller: _checklistItem,
                hint: 'Add checklist item',
                style: TaskFlowText.checklistItem(palette.textPrimary),
                onSubmitted: (_) => _addChecklistItem(),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _tagsBlock(TaskFlowPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in _tags)
                  GestureDetector(
                    onTap: () => setState(() => _tags.remove(tag)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: palette.groupedFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tag,
                              style: TaskFlowText.tag(palette.textSecondary)),
                          const SizedBox(width: 6),
                          Icon(Icons.close_rounded,
                              size: 12, color: palette.textQuaternary),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(Icons.add_rounded, size: 15, color: palette.accent),
              const SizedBox(width: 11),
              Expanded(
                child: _BareField(
                  controller: _tagItem,
                  hint: 'Add tag',
                  style: TaskFlowText.checklistItem(palette.textPrimary),
                  onSubmitted: (_) => _addTag(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---- Actions ------------------------------------------------------------

  void _addChecklistItem() {
    final value = _checklistItem.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _checklist.add(ChecklistItem(title: value));
      _checklistItem.clear();
    });
  }

  void _addTag() {
    final value = _tagItem.text.trim();
    if (value.isEmpty) return;
    final tag = value.startsWith('#') ? value.substring(1) : value;
    setState(() {
      if (!_tags.contains(tag)) _tags.add(tag);
      _tagItem.clear();
    });
  }

  Future<void> _pickWhen() async {
    final picked = await showModalBottomSheet<TaskWhen>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final when in TaskWhen.values)
              ListTile(
                leading: Icon(_whenIcon(when)),
                title: Text(_whenLabel(when)),
                selected: when == _when,
                onTap: () => Navigator.pop(sheet, when),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;

    if (picked == TaskWhen.date) {
      final date = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 730)),
        initialDate: _date ?? DateTime.now(),
      );
      if (date == null) return;
      setState(() {
        _when = TaskWhen.date;
        _date = date;
      });
      return;
    }

    setState(() {
      _when = picked;
      _date = null;
    });
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: _deadline ?? DateTime.now(),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _pickArea(TaskProvider provider) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('No area'),
              onTap: () => Navigator.pop(sheet, -1),
            ),
            for (final area in provider.areas)
              ListTile(
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Color(area.accentColor), shape: BoxShape.circle),
                ),
                title: Text(area.title),
                selected: area.id == _areaId,
                onTap: () => Navigator.pop(sheet, area.id),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      _areaId = picked == -1 ? null : picked;
      // A project belonging to a different area can't stay attached.
      final project = provider.projectById(_projectId);
      if (project != null &&
          project.areaId != null &&
          project.areaId != _areaId) {
        _projectId = null;
      }
    });
  }

  Future<void> _pickProject(TaskProvider provider) async {
    final available = _areaId == null
        ? provider.projects
        : provider.projects
            .where((project) =>
                project.areaId == _areaId || project.areaId == null)
            .toList();

    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('No project'),
              onTap: () => Navigator.pop(sheet, -1),
            ),
            for (final project in available)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(project.title),
                subtitle: project.areaId == null
                    ? null
                    : Text(provider.areaById(project.areaId)?.title ?? ''),
                selected: project.id == _projectId,
                onTap: () => Navigator.pop(sheet, project.id),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      _projectId = picked == -1 ? null : picked;
      _areaId = provider.projectById(_projectId)?.areaId ?? _areaId;
      final headings = provider.projectById(_projectId)?.headings ?? const [];
      if (!headings.contains(_heading)) _heading = null;
    });
  }

  Future<void> _pickHeading(TaskProvider provider) async {
    final headings = provider.projectById(_projectId)?.headings ?? const [];
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('No heading'),
              onTap: () => Navigator.pop(sheet, ''),
            ),
            for (final heading in headings)
              ListTile(
                leading: const Icon(Icons.segment_rounded),
                title: Text(heading),
                selected: heading == _heading,
                onTap: () => Navigator.pop(sheet, heading),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _heading = picked.isEmpty ? null : picked);
  }

  Future<void> _delete() async {
    final task = widget.task;
    if (task?.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Delete to-do'),
        content: Text('Delete "${task!.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Delete',
                style: TextStyle(color: TaskFlowTokens.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<TaskProvider>().deleteTask(task!.id!);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    final raw = _title.text.trim();
    if (raw.isEmpty) return;

    // Natural language only applies to a task being written for the first
    // time. Re-parsing on edit would quietly eat a word like "Friday" out of
    // a title the user had already settled on.
    var title = raw;
    var when = _when;
    var scheduled = _date;
    var recurrence = widget.task?.recurrence;

    if (_isNew) {
      final parsed = NaturalLanguageSchedule.parse(raw);
      if (parsed.title.isNotEmpty) title = parsed.title;
      if (_when == TaskWhen.inbox && _date == null) {
        when = parsed.when;
        scheduled = parsed.date;
        recurrence = parsed.recurrence;
      }
    }

    final task = Task(
      id: widget.task?.id,
      title: title,
      description: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      tags: _tags,
      checklist: _checklist,
      when: when,
      scheduledFor: when == TaskWhen.date ? scheduled : null,
      deadline: _deadline,
      projectId: _projectId?.toString(),
      areaId: _areaId?.toString(),
      heading: _heading,
      recurrence: recurrence,
      isCompleted: widget.task?.isCompleted ?? false,
      completedAt: widget.task?.completedAt,
      createdAt: widget.task?.createdAt,
    );

    final provider = context.read<TaskProvider>();
    if (_isNew) {
      await provider.addTask(task);
    } else {
      await provider.updateTask(task);
    }
    if (mounted) Navigator.pop(context);
  }

  static IconData _whenIcon(TaskWhen when) {
    switch (when) {
      case TaskWhen.inbox:
        return Icons.inbox_rounded;
      case TaskWhen.today:
        return Icons.star_rounded;
      case TaskWhen.evening:
        return Icons.nightlight_round;
      case TaskWhen.date:
        return Icons.calendar_today_rounded;
      case TaskWhen.anytime:
        return Icons.layers_rounded;
      case TaskWhen.someday:
        return Icons.archive_rounded;
    }
  }

  static String _whenLabel(TaskWhen when) {
    switch (when) {
      case TaskWhen.inbox:
        return 'Inbox';
      case TaskWhen.today:
        return 'Today';
      case TaskWhen.evening:
        return 'This Evening';
      case TaskWhen.date:
        return 'Upcoming';
      case TaskWhen.anytime:
        return 'Anytime';
      case TaskWhen.someday:
        return 'Someday';
    }
  }
}

/// Cancel on the left, a filled Done on the right — the same pair the
/// multi-select bar uses.
class _EditorBar extends StatelessWidget {
  const _EditorBar({required this.onCancel, required this.onDone});

  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCancel,
            child:
                Text('Cancel', style: TaskFlowText.textAction(palette.accent)),
          ),
          const Spacer(),
          TfPillButton(
            label: 'Done',
            onTap: onDone,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
        ],
      ),
    );
  }
}

/// A settable field: glyph, current value, and an optional clear.
class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.detail,
    this.iconColor,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final Color? iconColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: 17, color: iconColor ?? palette.textTertiary),
            const SizedBox(width: 13),
            Expanded(
              child: Text(label,
                  style: TaskFlowText.projectTitle(palette.textPrimary)),
            ),
            if (detail != null)
              Text(detail!, style: TaskFlowText.meta(palette.textTertiary)),
            if (onClear != null)
              TfGlyphButton(
                icon: Icons.close_rounded,
                size: 14,
                color: palette.textQuaternary,
                onTap: onClear!,
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.chevron_right_rounded,
                    size: 18, color: palette.controlBorder),
              ),
          ],
        ),
      ),
    );
  }
}

/// Chrome-free text field, matching quick capture.
class _BareField extends StatelessWidget {
  const _BareField({
    required this.controller,
    required this.hint,
    required this.style,
    this.autofocus = false,
    this.maxLines = 1,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final TextStyle style;
  final bool autofocus;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: 1,
      style: style,
      textCapitalization: TextCapitalization.sentences,
      textInputAction:
          maxLines == 1 ? TextInputAction.done : TextInputAction.newline,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: hint,
        hintStyle: style.copyWith(color: palette.textQuaternary),
      ),
    );
  }
}
