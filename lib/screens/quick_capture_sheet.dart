import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../design/taskflow_tokens.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/natural_language_schedule.dart';
import '../widgets/tf_widgets.dart';

/// Opens quick capture as a card near the top of the screen, over a dimmed
/// copy of wherever you were. Nothing is pushed, so saving returns you exactly
/// where you started.
Future<void> showQuickCapture(
  BuildContext context, {
  TaskWhen initialWhen = TaskWhen.inbox,
  String? projectId,
  String? areaId,
  String? heading,
  ValueChanged<Task>? onCreated,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'New to-do',
    barrierColor: context.palette.scrim,
    transitionDuration: const Duration(milliseconds: 180),
    // showGeneralDialog builds outside any Material ancestor, which would
    // leave every Text with the framework's fallback underline.
    pageBuilder: (_, __, ___) => Material(
      type: MaterialType.transparency,
      child: QuickCaptureSheet(
        initialWhen: initialWhen,
        projectId: projectId,
        areaId: areaId,
        heading: heading,
        onCreated: onCreated,
      ),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.04), end: Offset.zero)
              .animate(curved),
          child: child,
        ),
      );
    },
  );
}

class QuickCaptureSheet extends StatefulWidget {
  const QuickCaptureSheet({
    super.key,
    this.initialWhen = TaskWhen.inbox,
    this.projectId,
    this.areaId,
    this.heading,
    this.onCreated,
  });

  final TaskWhen initialWhen;
  final String? projectId;
  final String? areaId;
  final String? heading;
  final ValueChanged<Task>? onCreated;

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
  DateTime? _deadline;
  late TaskWhen _when;
  bool _showChecklist = false;
  bool _showTags = false;

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

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              14, 22, 14, MediaQuery.viewInsetsOf(context).bottom + 22),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(TaskFlowTokens.radiusLg),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2)),
                BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 48,
                    spreadRadius: -14,
                    offset: const Offset(0, 24)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _fields(palette),
                if (_showChecklist) _checklistEditor(palette),
                if (_showTags) _tagEditor(palette),
                if (_date != null || _deadline != null) _scheduleSummary(palette),
                _actionRow(palette),
                Container(height: 1, color: palette.separator),
                _footer(palette),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fields(TaskFlowPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: TfCheckbox(checked: false),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _BareField(
                  controller: _title,
                  hint: 'New To-Do',
                  autofocus: true,
                  style: TaskFlowText.openTaskTitle(palette.textPrimary),
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 8),
                _BareField(
                  controller: _notes,
                  hint: 'Notes',
                  maxLines: 3,
                  style: TextStyle(
                      color: palette.textPrimary, fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: TfCircleButton(
              icon: Icons.close_rounded,
              diameter: 28,
              iconSize: 15,
              tooltip: 'Discard',
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checklistEditor(TaskFlowPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _checklist.length; i++)
            Row(
              children: [
                TfChecklistMark(
                  checked: _checklist[i].isCompleted,
                  onTap: () => setState(() => _checklist[i] = _checklist[i]
                      .copyWith(isCompleted: !_checklist[i].isCompleted)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(_checklist[i].title,
                      style:
                          TaskFlowText.checklistItem(palette.textPrimary)),
                ),
                TfGlyphButton(
                  icon: Icons.close_rounded,
                  size: 14,
                  color: palette.textQuaternary,
                  onTap: () => setState(() => _checklist.removeAt(i)),
                ),
              ],
            ),
          _BareField(
            controller: _checklistController,
            hint: 'Add checklist item',
            autofocus: true,
            style: TaskFlowText.checklistItem(palette.textPrimary),
            onSubmitted: (_) => _addChecklistItem(),
          ),
        ],
      ),
    );
  }

  Widget _tagEditor(TaskFlowPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
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
                        child: Text(tag,
                            style: TaskFlowText.tag(palette.textSecondary)),
                      ),
                    ),
                ],
              ),
            ),
          _BareField(
            controller: _tagController,
            hint: 'Add tag',
            autofocus: true,
            style: TaskFlowText.checklistItem(palette.textPrimary),
            onSubmitted: (_) => _addTag(),
          ),
        ],
      ),
    );
  }

  Widget _scheduleSummary(TaskFlowPalette palette) {
    final format = DateFormat('EEE, MMM d');
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 10, 16, 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          if (_date != null)
            _SummaryChip(
              icon: Icons.calendar_today_rounded,
              label: format.format(_date!),
              onClear: () => setState(() {
                _date = null;
                if (_when == TaskWhen.date) _when = TaskWhen.inbox;
              }),
            ),
          if (_deadline != null)
            _SummaryChip(
              icon: Icons.flag_rounded,
              label: 'Deadline ${format.format(_deadline!)}',
              color: palette.danger,
              onClear: () => setState(() => _deadline = null),
            ),
        ],
      ),
    );
  }

  Widget _actionRow(TaskFlowPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _CaptureAction(
            icon: Icons.calendar_today_outlined,
            tooltip: 'When',
            active: _date != null,
            onTap: _pickDate,
          ),
          const SizedBox(width: 22),
          _CaptureAction(
            icon: Icons.sell_outlined,
            tooltip: 'Tags',
            active: _showTags || _tags.isNotEmpty,
            onTap: () => setState(() => _showTags = !_showTags),
          ),
          const SizedBox(width: 22),
          _CaptureAction(
            icon: Icons.checklist_rounded,
            tooltip: 'Checklist',
            active: _showChecklist || _checklist.isNotEmpty,
            onTap: () => setState(() => _showChecklist = !_showChecklist),
          ),
          const SizedBox(width: 22),
          _CaptureAction(
            icon: Icons.flag_outlined,
            tooltip: 'Deadline',
            active: _deadline != null,
            onTap: _pickDeadline,
          ),
        ],
      ),
    );
  }

  Widget _footer(TaskFlowPalette palette) {
    return Container(
      color: palette.footerFill,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pickDestination,
              child: Row(
                children: [
                  Icon(_destinationIcon(_when),
                      size: 17, color: palette.textTertiary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(_destinationLabel(_when),
                        style: TextStyle(
                            color: palette.textTertiary,
                            fontSize: 15,
                            height: 1.2),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: palette.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          TfPillButton(
            label: 'Save',
            onTap: _save,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          ),
        ],
      ),
    );
  }

  // ---- Actions ------------------------------------------------------------

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: _date ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _when = TaskWhen.date;
    });
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: _deadline ?? DateTime.now(),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _pickDestination() async {
    final picked = await showModalBottomSheet<TaskWhen>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final when in TaskWhen.values)
              ListTile(
                leading: Icon(_destinationIcon(when)),
                title: Text(_destinationLabel(when)),
                selected: when == _when,
                onTap: () => Navigator.pop(sheet, when),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _when = picked);
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

  Future<void> _save() async {
    // Natural language in the title still wins when no destination was chosen
    // by hand — "call Mum friday" lands on Friday without touching the picker.
    final parsed = NaturalLanguageSchedule.parse(_title.text.trim());
    final title = parsed.title.isEmpty ? _title.text.trim() : parsed.title;
    if (title.isEmpty) return;

    final usesParsedWhen = _when == TaskWhen.inbox && _date == null;
    final when = usesParsedWhen ? parsed.when : _when;
    final scheduled = when == TaskWhen.date ? (_date ?? parsed.date) : null;

    final task = Task(
      title: title,
      description: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      checklist: _checklist,
      tags: _tags,
      when: when,
      scheduledFor: scheduled,
      deadline: _deadline,
      projectId: widget.projectId,
      areaId: widget.areaId,
      heading: widget.heading,
      recurrence: usesParsedWhen ? parsed.recurrence : null,
    );

    final stored = await context.read<TaskProvider>().addTask(task);
    widget.onCreated?.call(stored);
    if (mounted) Navigator.pop(context);
  }

  static IconData _destinationIcon(TaskWhen when) {
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

  static String _destinationLabel(TaskWhen when) {
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

/// A text field with no chrome at all — capture should look like writing on
/// paper, not filling in a form.
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

class _CaptureAction extends StatelessWidget {
  const _CaptureAction({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(icon,
              size: 20,
              color: active ? palette.accent : palette.controlBorder),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.onClear,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onClear;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tint = color ?? palette.accent;
    return GestureDetector(
      onTap: onClear,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: palette.groupedFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: tint),
            const SizedBox(width: 6),
            Text(label, style: TaskFlowText.tag(palette.textSecondary)),
            const SizedBox(width: 6),
            Icon(Icons.close_rounded, size: 13, color: palette.textQuaternary),
          ],
        ),
      ),
    );
  }
}
