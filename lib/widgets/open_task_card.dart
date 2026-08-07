import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design/taskflow_tokens.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/add_edit_task_screen.dart';
import 'tf_widgets.dart';

/// A task opened in place.
///
/// Rather than pushing a detail screen, the row it replaces grows into this
/// card while the surrounding list dims — so you never lose your position in
/// the list you were reading.
class OpenTaskCard extends StatelessWidget {
  const OpenTaskCard({super.key, required this.task, required this.onClose});

  final Task task;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<TaskProvider>();
    final indent = TaskFlowTokens.checkbox + 12;

    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(TaskFlowTokens.radiusMd),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 1,
              offset: const Offset(0, 1)),
          BoxShadow(
              color: Colors.black.withOpacity(0.24),
              blurRadius: 30,
              spreadRadius: -10,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TfCheckbox(
                checked: task.isCompleted,
                onTap: () => provider.toggleTaskCompletion(task),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(task.title,
                    style: TaskFlowText.openTaskTitle(palette.textPrimary)),
              ),
            ],
          ),
          if ((task.description ?? '').isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: indent, top: 10),
              child: Text(task.description!,
                  style: TaskFlowText.notes(palette.textSecondary)),
            ),
          if (task.checklist.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: indent, top: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < task.checklist.length; i++)
                    _ChecklistRow(
                      item: task.checklist[i],
                      onToggle: () => _toggleChecklistItem(context, i),
                    ),
                ],
              ),
            ),
          if (task.tags.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: indent, top: 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final tag in task.tags) _TagChip(label: tag)],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: indent, top: 12),
            child: Container(height: 1, color: palette.hairline),
          ),
          Padding(
            padding: EdgeInsets.only(left: indent, top: 11, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _breadcrumb(provider),
                    style: TaskFlowText.meta(palette.textQuaternary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _TextAction(
                  label: 'Edit',
                  color: palette.accent,
                  onTap: () {
                    onClose();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddEditTaskScreen(task: task)),
                    );
                  },
                ),
                const SizedBox(width: 20),
                _TextAction(
                  label: 'Delete',
                  color: palette.danger,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleChecklistItem(BuildContext context, int index) {
    final updated = List<ChecklistItem>.of(task.checklist);
    updated[index] =
        updated[index].copyWith(isCompleted: !updated[index].isCompleted);
    context.read<TaskProvider>().updateTask(task.copyWith(checklist: updated));
  }

  String _breadcrumb(TaskProvider provider) {
    final area = provider.areaById(int.tryParse(task.areaId ?? ''));
    final project = provider.projectById(int.tryParse(task.projectId ?? ''));
    final parts = [
      if (area != null) area.title,
      if (project != null) project.title,
    ];
    if (parts.isEmpty) return _whenLabel(task.when);
    return parts.join(' · ');
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

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<TaskProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Delete to-do'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text('Delete',
                style: TextStyle(color: TaskFlowTokens.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || task.id == null) return;
    onClose();
    await provider.deleteTask(task.id!);
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item, required this.onToggle});

  final ChecklistItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 1, color: palette.hairline),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                TfChecklistMark(checked: item.isCompleted, onTap: onToggle),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(item.title,
                      style:
                          TaskFlowText.checklistItem(palette.textPrimary)),
                ),
                Icon(Icons.drag_handle_rounded,
                    size: 15, color: palette.controlBorder),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: palette.groupedFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TaskFlowText.tag(palette.textSecondary)),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
            color: color,
            fontSize: 14.5,
            height: 1,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
