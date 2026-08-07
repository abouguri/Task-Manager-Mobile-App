import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design/taskflow_tokens.dart';
import '../models/organization.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/open_task_card.dart';
import '../widgets/task_row.dart';
import '../widgets/tf_widgets.dart';
import 'quick_capture_sheet.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  /// Headings live for the life of the screen; a task belongs to whichever
  /// heading it was dragged onto, and to the first one otherwise.
  static const String _defaultHeading = 'General';
  final List<String> _headings = [_defaultHeading];
  final Map<int, String> _headingByTask = {};
  final TextEditingController _headingController = TextEditingController();
  int? _openTaskId;

  @override
  void dispose() {
    _headingController.dispose();
    super.dispose();
  }

  void _addHeading() {
    final value = _headingController.text.trim();
    if (value.isEmpty || _headings.contains(value)) return;
    setState(() {
      _headings.add(value);
      _headingController.clear();
    });
  }

  void _addTask(String heading) {
    showQuickCapture(
      context,
      initialWhen: TaskWhen.anytime,
      projectId: widget.project.id?.toString(),
      areaId: widget.project.areaId?.toString(),
      onCreated: (task) {
        final id = task.id;
        if (id != null) setState(() => _headingByTask[id] = heading);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<TaskProvider>();
    final area = provider.areaById(widget.project.areaId);
    final tasks = provider.allTasks
        .where((task) =>
            int.tryParse(task.projectId ?? '') == widget.project.id &&
            !task.isCompleted)
        .toList();

    return Scaffold(
      backgroundColor:
          _openTaskId == null ? palette.surface : palette.elevatedSurface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                TfNavBar(
                  onBack: () => Navigator.pop(context),
                  trailing: [
                    TfGlyphButton(
                      icon: Icons.download_outlined,
                      size: 19,
                      color: palette.textTertiary,
                      tooltip: 'Move project',
                      onTap: _moveProject,
                    ),
                    const SizedBox(width: 8),
                    TfCircleButton(
                      icon: Icons.more_horiz_rounded,
                      tooltip: 'Project actions',
                      onTap: _projectMenu,
                    ),
                  ],
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: _openTaskId == null
                        ? HitTestBehavior.deferToChild
                        : HitTestBehavior.opaque,
                    onTap: _openTaskId == null
                        ? null
                        : () => setState(() => _openTaskId = null),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(TaskFlowTokens.gutter - _bleed,
                          14, TaskFlowTokens.gutter - _bleed, 100),
                      children: [
                        _dim(_ProjectHeader(
                            project: widget.project, area: area)),
                        for (final heading in _headings)
                          ..._section(provider, heading, tasks),
                        _dim(Padding(
                          padding: const EdgeInsets.only(top: 26),
                          child: _AddHeadingField(
                            controller: _headingController,
                            onSubmit: _addHeading,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_openTaskId == null)
              Positioned(
                right: 24,
                bottom: 30,
                child: TfFab(onTap: () => _addTask(_headings.first)),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _section(
      TaskProvider provider, String heading, List<Task> allTasks) {
    final isFirst = heading == _headings.first;
    final tasks = allTasks.where((task) {
      final assigned = _headingByTask[task.id];
      return assigned == heading || (assigned == null && isFirst);
    }).toList();

    return [
      _dim(DragTarget<Task>(
        onAcceptWithDetails: (details) {
          final id = details.data.id;
          if (id != null) setState(() => _headingByTask[id] = heading);
        },
        builder: (context, candidate, __) => Container(
          decoration: BoxDecoration(
            color: candidate.isEmpty
                ? Colors.transparent
                : context.palette.accent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(TaskFlowTokens.radiusChip),
          ),
          child: TfSectionHeader(
            title: heading,
            onAdd: () => _addTask(heading),
            onOverflow: () => _headingMenu(heading),
          ),
        ),
      )),
      if (tasks.isEmpty)
        _dim(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 2),
          child: Text('Drop to-dos here, or add one.',
              style: TaskFlowText.meta(context.palette.textQuaternary)),
        )),
      for (final task in tasks) ..._row(provider, task),
    ];
  }

  List<Widget> _row(TaskProvider provider, Task task) {
    if (_openTaskId != null && _openTaskId == task.id) {
      return [
        OpenTaskCard(
          task: task,
          onClose: () => setState(() => _openTaskId = null),
        ),
      ];
    }

    final row = TfTaskRow(
      title: task.title,
      checked: task.isCompleted,
      dense: true,
      onToggle: () => provider.toggleTaskCompletion(task),
      onTap: () => setState(() => _openTaskId = task.id),
      trailing: [
        if ((task.description ?? '').isNotEmpty) TfRowGlyphs.note(context),
        if (task.checklist.isNotEmpty)
          TfBadge(
              label:
                  '${task.checklist.where((item) => item.isCompleted).length}/${task.checklist.length}'),
        if (task.tags.isNotEmpty) TfRowGlyphs.tag(context),
      ],
    );

    return [
      _dim(LongPressDraggable<Task>(
        data: task,
        feedback: _DragChip(title: task.title),
        childWhenDragging: Opacity(opacity: 0.4, child: row),
        child: row,
      )),
    ];
  }

  /// The open card reaches past the text gutter; the list widens to let it and
  /// everything else is inset back by the same amount.
  double get _bleed => _openTaskId != null ? 6 : 0;

  Widget _dim(Widget child) => _openTaskId == null
      ? child
      : Opacity(
          opacity: 0.4,
          child: IgnorePointer(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _bleed),
                child: child),
          ),
        );

  Future<void> _headingMenu(String heading) async {
    if (heading == _headings.first) return;
    final remove = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline_rounded),
          title: Text('Remove "$heading"'),
          subtitle: const Text('To-dos move back to the first heading.'),
          onTap: () => Navigator.pop(sheet, true),
        ),
      ),
    );
    if (remove != true) return;
    setState(() {
      _headings.remove(heading);
      _headingByTask.removeWhere((_, value) => value == heading);
    });
  }

  Future<void> _moveProject() async {
    final provider = context.read<TaskProvider>();
    final areaId = await showModalBottomSheet<int?>(
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
                onTap: () => Navigator.pop(sheet, area.id),
              ),
          ],
        ),
      ),
    );
    if (areaId == null) return;
    await provider.updateProject(
        widget.project.copyWith(areaId: areaId == -1 ? null : areaId));
  }

  Future<void> _projectMenu() async {
    final provider = context.read<TaskProvider>();
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline_rounded),
              title: Text(widget.project.isCompleted
                  ? 'Reopen project'
                  : 'Complete project'),
              onTap: () => Navigator.pop(sheet, 'complete'),
            ),
          ],
        ),
      ),
    );
    if (action != 'complete') return;
    await provider.toggleProject(widget.project);
    if (mounted) Navigator.pop(context);
  }
}

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader({required this.project, required this.area});

  final Project project;
  final Area? area;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: palette.accent.withOpacity(0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.folder_rounded, size: 19, color: palette.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.title,
                  style: TaskFlowText.title1(palette.textPrimary)),
              if (area != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    area!.title,
                    style: TextStyle(
                      color: palette.textTertiary,
                      fontSize: 14,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddHeadingField extends StatelessWidget {
  const _AddHeadingField({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: palette.groupedFill,
        borderRadius: BorderRadius.circular(TaskFlowTokens.radiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSubmit(),
              textInputAction: TextInputAction.done,
              style: TextStyle(
                  color: palette.textPrimary, fontSize: 15, height: 1.2),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintText: 'Add heading',
                hintStyle: TextStyle(
                    color: palette.textQuaternary, fontSize: 15, height: 1.2),
              ),
            ),
          ),
          TfGlyphButton(
              icon: Icons.add_rounded, size: 17, onTap: onSubmit),
        ],
      ),
    );
  }
}

class _DragChip extends StatelessWidget {
  const _DragChip({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(TaskFlowTokens.radiusMd),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Text(title, style: TaskFlowText.taskTitle(palette.textPrimary)),
      ),
    );
  }
}
