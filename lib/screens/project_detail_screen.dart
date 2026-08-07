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
  final TextEditingController _headingController = TextEditingController();
  int? _openTaskId;

  /// Tracks a drag so the "no heading" drop zone only appears when it is
  /// actually usable, instead of sitting there as permanent clutter.
  bool _dragging = false;

  @override
  void dispose() {
    _headingController.dispose();
    super.dispose();
  }

  /// The stored project, not the snapshot this screen was pushed with — its
  /// headings change while the screen is open.
  Project _project(TaskProvider provider) =>
      provider.projectById(widget.project.id) ?? widget.project;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<TaskProvider>();
    final project = _project(provider);
    final area = provider.areaById(project.areaId);

    final tasks = provider.allTasks
        .where((task) =>
            int.tryParse(task.projectId ?? '') == project.id &&
            !task.isCompleted)
        .toList();

    // A heading removed while tasks still pointed at it leaves them orphaned;
    // treat those as unfiled rather than hiding them.
    final known = project.headings.toSet();
    final loose = tasks
        .where((task) => task.heading == null || !known.contains(task.heading))
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
                      onTap: () => _moveProject(project),
                    ),
                    const SizedBox(width: 8),
                    TfCircleButton(
                      icon: Icons.more_horiz_rounded,
                      tooltip: 'Project actions',
                      onTap: () => _projectMenu(project),
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
                      padding: EdgeInsets.fromLTRB(
                          TaskFlowTokens.gutter - _bleed,
                          14,
                          TaskFlowTokens.gutter - _bleed,
                          100),
                      children: [
                        _dim(_ProjectHeader(project: project, area: area)),
                        const SizedBox(height: 6),
                        ..._looseSection(provider, project, loose),
                        for (final heading in project.headings)
                          ..._section(provider, project, heading, tasks),
                        _dim(Padding(
                          padding: const EdgeInsets.only(top: 26),
                          child: _AddHeadingField(
                            controller: _headingController,
                            onSubmit: () => _addHeading(project),
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
                child: TfFab(onTap: () => _addTask(project, null)),
              ),
          ],
        ),
      ),
    );
  }

  /// Tasks that belong to the project but sit above the first heading.
  List<Widget> _looseSection(
      TaskProvider provider, Project project, List<Task> loose) {
    final showDropZone =
        _dragging && project.headings.isNotEmpty && _openTaskId == null;

    return [
      if (showDropZone)
        _dim(_DropZone(
          label: 'No heading',
          onAccept: (task) => _moveTaskToHeading(task, null),
        )),
      for (final task in loose) ..._row(provider, task),
    ];
  }

  List<Widget> _section(TaskProvider provider, Project project, String heading,
      List<Task> allTasks) {
    final tasks =
        allTasks.where((task) => task.heading == heading).toList();

    return [
      _dim(DragTarget<Task>(
        onAcceptWithDetails: (details) =>
            _moveTaskToHeading(details.data, heading),
        builder: (context, candidate, __) => Container(
          decoration: BoxDecoration(
            color: candidate.isEmpty
                ? Colors.transparent
                : context.palette.accent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(TaskFlowTokens.radiusChip),
          ),
          child: TfSectionHeader(
            title: heading,
            onAdd: () => _addTask(project, heading),
            onOverflow: () => _headingMenu(project, heading),
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
        onDragStarted: () => setState(() => _dragging = true),
        onDragEnd: (_) => setState(() => _dragging = false),
        onDraggableCanceled: (_, __) => setState(() => _dragging = false),
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

  // ---- Mutations ----------------------------------------------------------

  Future<void> _moveTaskToHeading(Task task, String? heading) async {
    setState(() => _dragging = false);
    if (task.heading == heading) return;
    await context.read<TaskProvider>().updateTask(
        heading == null
            ? task.copyWith(clearHeading: true)
            : task.copyWith(heading: heading));
  }

  Future<void> _addHeading(Project project) async {
    final value = _headingController.text.trim();
    if (value.isEmpty || project.headings.contains(value)) return;
    _headingController.clear();
    await context
        .read<TaskProvider>()
        .updateProject(project.copyWith(headings: [...project.headings, value]));
  }

  void _addTask(Project project, String? heading) {
    showQuickCapture(
      context,
      initialWhen: TaskWhen.anytime,
      projectId: project.id?.toString(),
      areaId: project.areaId?.toString(),
      heading: heading,
    );
  }

  Future<void> _headingMenu(Project project, String heading) async {
    final provider = context.read<TaskProvider>();
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: const Text('Rename heading'),
              onTap: () => Navigator.pop(sheet, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text('Remove "$heading"'),
              subtitle: const Text('Its to-dos move above the first heading.'),
              onTap: () => Navigator.pop(sheet, 'remove'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    if (action == 'rename') {
      await _renameHeading(provider, project, heading);
      return;
    }

    final headings = [...project.headings]..remove(heading);
    await provider.updateProject(project.copyWith(headings: headings));
    for (final task in provider.allTasks.where((task) =>
        task.heading == heading &&
        int.tryParse(task.projectId ?? '') == project.id)) {
      await provider.updateTask(task.copyWith(clearHeading: true));
    }
  }

  Future<void> _renameHeading(
      TaskProvider provider, Project project, String heading) async {
    final controller = TextEditingController(text: heading);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Rename heading'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.pop(dialog, true),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: const Text('Rename')),
        ],
      ),
    );
    final value = controller.text.trim();
    controller.dispose();
    if (confirmed != true ||
        value.isEmpty ||
        value == heading ||
        project.headings.contains(value)) {
      return;
    }

    await provider.updateProject(project.copyWith(
      headings: [
        for (final item in project.headings) item == heading ? value : item,
      ],
    ));
    // Tasks reference a heading by name, so they have to follow the rename.
    for (final task in provider.allTasks.where((task) =>
        task.heading == heading &&
        int.tryParse(task.projectId ?? '') == project.id)) {
      await provider.updateTask(task.copyWith(heading: value));
    }
  }

  Future<void> _moveProject(Project project) async {
    final provider = context.read<TaskProvider>();
    final areaId = await showModalBottomSheet<int>(
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
    await provider
        .updateProject(project.copyWith(areaId: areaId == -1 ? null : areaId));
  }

  Future<void> _projectMenu(Project project) async {
    final provider = context.read<TaskProvider>();
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline_rounded),
              title: Text(project.isCompleted
                  ? 'Reopen project'
                  : 'Complete project'),
              onTap: () => Navigator.pop(sheet, 'complete'),
            ),
          ],
        ),
      ),
    );
    if (action != 'complete') return;
    await provider.toggleProject(project);
    if (mounted) Navigator.pop(context);
  }
}

/// Appears mid-drag so a to-do can be pulled back out of a heading.
class _DropZone extends StatelessWidget {
  const _DropZone({required this.label, required this.onAccept});

  final String label;
  final ValueChanged<Task> onAccept;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DragTarget<Task>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, __) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: candidate.isEmpty
              ? palette.groupedFill
              : palette.accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(TaskFlowTokens.radiusChip),
        ),
        child: Text(label,
            style: TaskFlowText.meta(
                candidate.isEmpty ? palette.textQuaternary : palette.accent)),
      ),
    );
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
              textCapitalization: TextCapitalization.sentences,
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
          TfGlyphButton(icon: Icons.add_rounded, size: 17, onTap: onSubmit),
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
