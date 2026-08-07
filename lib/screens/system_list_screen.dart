import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../design/taskflow_tokens.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/open_task_card.dart';
import '../widgets/task_row.dart';
import '../widgets/tf_widgets.dart';
import 'quick_capture_sheet.dart';

enum SystemListKind { inbox, today, upcoming, anytime, someday, logbook }

class SystemListScreen extends StatefulWidget {
  const SystemListScreen({super.key, required this.kind, this.focusTaskId});

  final SystemListKind kind;

  /// Task to open inline as soon as the list appears — used when arriving from
  /// Quick Find.
  final int? focusTaskId;

  @override
  State<SystemListScreen> createState() => _SystemListScreenState();
}

class _SystemListScreenState extends State<SystemListScreen> {
  int? _openTaskId;
  final Set<int> _selected = <int>{};
  bool _selecting = false;

  @override
  void initState() {
    super.initState();
    _openTaskId = widget.focusTaskId;
  }

  bool get _isToday => widget.kind == SystemListKind.today;
  bool get _isUpcoming => widget.kind == SystemListKind.upcoming;

  void _open(Task task) => setState(() => _openTaskId = task.id);
  void _close() => setState(() => _openTaskId = null);

  void _startSelecting(Task task) {
    if (task.id == null) return;
    setState(() {
      _selecting = true;
      _openTaskId = null;
      _selected
        ..clear()
        ..add(task.id!);
    });
  }

  void _toggleSelected(Task task) {
    if (task.id == null) return;
    setState(() {
      if (!_selected.remove(task.id)) _selected.add(task.id!);
    });
  }

  void _endSelecting() => setState(() {
        _selecting = false;
        _selected.clear();
      });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<TaskProvider>();
    final tasks = _tasksForKind(provider);

    return Scaffold(
      backgroundColor:
          _openTaskId == null ? palette.surface : palette.elevatedSurface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _selecting
                    ? _SelectionBar(
                        onSelectAll: () => setState(() => _selected
                          ..clear()
                          ..addAll(tasks
                              .map((task) => task.id)
                              .whereType<int>())),
                        onDone: _endSelecting,
                      )
                    : TfNavBar(
                        onBack: () => Navigator.pop(context),
                        middle: _isUpcoming
                            ? _NavListChip(
                                icon: _iconForKind(widget.kind),
                                color: _accentForKind(widget.kind),
                                title: _titleForKind(widget.kind),
                              )
                            : null,
                        trailing: [
                          TfCircleButton(
                            icon: Icons.more_horiz_rounded,
                            tooltip: 'List actions',
                            onTap: () => _showListMenu(tasks),
                          ),
                        ],
                      ),
                Expanded(
                  child: GestureDetector(
                    behavior: _openTaskId == null
                        ? HitTestBehavior.deferToChild
                        : HitTestBehavior.opaque,
                    onTap: _openTaskId == null ? null : _close,
                    child: tasks.isEmpty
                        ? _EmptyState(title: _titleForKind(widget.kind))
                        : ListView(
                            padding: EdgeInsets.fromLTRB(
                                TaskFlowTokens.gutter - _bleed,
                                _isUpcoming ? 10 : 14,
                                TaskFlowTokens.gutter - _bleed,
                                _selecting ? 120 : 100),
                            children: _buildBody(provider, tasks),
                          ),
                  ),
                ),
              ],
            ),
            if (_selecting)
              Positioned(
                left: 20,
                right: 20,
                bottom: 28,
                child: _SelectionToolbar(
                  count: _selected.length,
                  onWhen: _rescheduleSelection,
                  onMove: _moveSelection,
                  onDelete: _deleteSelection,
                  onMore: _selectionOverflow,
                ),
              )
            else if (_openTaskId == null)
              Positioned(
                right: 24,
                bottom: 30,
                child: TfFab(
                    onTap: () =>
                        showQuickCapture(context, initialWhen: _whenForKind())),
              ),
          ],
        ),
      ),
    );
  }

  // ---- Body ---------------------------------------------------------------

  List<Widget> _buildBody(TaskProvider provider, List<Task> tasks) {
    if (_isUpcoming) return _buildUpcoming(provider, tasks);
    if (_isToday) return _buildToday(provider, tasks);

    return [
      _dim(_ScreenTitle(
          title: _titleForKind(widget.kind),
          icon: _iconForKind(widget.kind),
          color: _accentForKind(widget.kind))),
      const SizedBox(height: 6),
      for (final task in tasks) ..._row(provider, task),
    ];
  }

  List<Widget> _buildToday(TaskProvider provider, List<Task> tasks) {
    final agenda = _agendaForToday(provider);
    final daytime =
        tasks.where((task) => task.when != TaskWhen.evening).toList();
    final evening =
        tasks.where((task) => task.when == TaskWhen.evening).toList();

    return [
      _dim(_ScreenTitle(
          title: 'Today',
          icon: Icons.star_rounded,
          color: TaskFlowTokens.todayAccent)),
      const SizedBox(height: 16),
      if (agenda.isNotEmpty) ...[
        _dim(_AgendaCard(entries: agenda)),
        const SizedBox(height: 20),
      ],
      for (final task in daytime) ..._row(provider, task),
      if (evening.isNotEmpty) ...[
        _dim(Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
          child: Row(
            children: [
              const Icon(Icons.nightlight_round,
                  size: 17, color: TaskFlowTokens.eveningAccent),
              const SizedBox(width: 8),
              Text('This Evening',
                  style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 15,
                      height: 1.2,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        )),
        for (final task in evening) ..._row(provider, task),
      ],
    ];
  }

  List<Widget> _buildUpcoming(TaskProvider provider, List<Task> tasks) {
    final grouped = <DateTime, List<Task>>{};
    for (final task in tasks) {
      final day = _dayOnly(task.scheduledFor ?? task.createdAt);
      grouped.putIfAbsent(day, () => <Task>[]).add(task);
    }
    final days = grouped.keys.toList()..sort();

    return [
      for (final day in days) ...[
        _dim(_DayHeader(date: day)),
        const SizedBox(height: 8),
        for (final task in grouped[day]!) ..._row(provider, task),
      ],
    ];
  }

  /// One task, in whichever of the three states the screen is in.
  List<Widget> _row(TaskProvider provider, Task task) {
    if (_selecting) {
      return [
        TfSelectableTaskRow(
          title: task.title,
          subtitle: _subtitleFor(provider, task),
          checked: task.isCompleted,
          selected: _selected.contains(task.id),
          onSelect: () => _toggleSelected(task),
        ),
      ];
    }

    if (_openTaskId != null && _openTaskId == task.id) {
      return [OpenTaskCard(task: task, onClose: _close)];
    }

    return [
      _dim(TfTaskRow(
        title: task.title,
        subtitle: _subtitleFor(provider, task),
        checked: task.isCompleted,
        inlineBadge: _isUpcoming && task.checklist.isNotEmpty
            ? '${task.checklist.where((item) => item.isCompleted).length}/${task.checklist.length}'
            : null,
        onToggle: () => provider.toggleTaskCompletion(task),
        onTap: () => _open(task),
        onLongPress: () => _startSelecting(task),
        trailing: _trailingFor(task),
      )),
    ];
  }

  /// How far the selection band / open card reaches past the text gutter. The
  /// list widens by this much and everything else is inset back, which is the
  /// only way to bleed without negative margins.
  double get _bleed => _selecting ? 8 : (_openTaskId != null ? 6 : 0);

  /// Headers and collapsed rows: held at the text gutter, and faded out while
  /// another task is open so the card reads as the only live thing on screen.
  Widget _dim(Widget child) {
    var result = child;
    if (_bleed > 0) {
      result = Padding(
          padding: EdgeInsets.symmetric(horizontal: _bleed), child: result);
    }
    if (_openTaskId != null) {
      result = Opacity(opacity: 0.4, child: IgnorePointer(child: result));
    }
    return result;
  }

  List<Widget> _trailingFor(Task task) {
    final deadline = task.deadline;
    if (deadline == null) return const [];
    final today = _dayOnly(DateTime.now());
    final day = _dayOnly(deadline);
    final days = day.difference(today).inDays;

    if (days <= 0) {
      return [TfFlag(label: 'today', color: context.palette.danger)];
    }
    return [TfRowGlyphs.deadline(context, '${days}d left')];
  }

  String? _subtitleFor(TaskProvider provider, Task task) {
    final project = provider.projectById(int.tryParse(task.projectId ?? ''));
    if (project != null) return project.title;
    final area = provider.areaById(int.tryParse(task.areaId ?? ''));
    return area?.title;
  }

  // ---- Selection actions --------------------------------------------------

  List<Task> _selectedTasks(TaskProvider provider) => provider.allTasks
      .where((task) => task.id != null && _selected.contains(task.id))
      .toList();

  Future<void> _rescheduleSelection() async {
    final provider = context.read<TaskProvider>();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: DateTime.now(),
    );
    if (picked == null) return;
    for (final task in _selectedTasks(provider)) {
      await provider.moveTo(task, TaskWhen.date, date: picked);
    }
    _endSelecting();
  }

  Future<void> _moveSelection() async {
    final provider = context.read<TaskProvider>();
    final projects =
        provider.projects.where((project) => !project.isCompleted).toList();

    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.inbox_rounded),
              title: const Text('Inbox'),
              onTap: () => Navigator.pop(sheet, 'inbox'),
            ),
            for (final project in projects)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(project.title),
                onTap: () => Navigator.pop(sheet, '${project.id}'),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;

    for (final task in _selectedTasks(provider)) {
      if (choice == 'inbox') {
        await provider.updateTask(
            task.copyWith(projectId: null, when: TaskWhen.inbox));
      } else {
        final project = provider.projectById(int.tryParse(choice));
        await provider.updateTask(task.copyWith(
          projectId: choice,
          areaId: project?.areaId?.toString() ?? task.areaId,
        ));
      }
    }
    _endSelecting();
  }

  Future<void> _deleteSelection() async {
    final provider = context.read<TaskProvider>();
    final tasks = _selectedTasks(provider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(tasks.length == 1
            ? 'Delete to-do'
            : 'Delete ${tasks.length} to-dos'),
        content: const Text('This cannot be undone.'),
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
    if (confirmed != true) return;
    for (final task in tasks) {
      if (task.id != null) await provider.deleteTask(task.id!);
    }
    _endSelecting();
  }

  Future<void> _selectionOverflow() async {
    final provider = context.read<TaskProvider>();
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline_rounded),
              title: const Text('Mark complete'),
              onTap: () => Navigator.pop(sheet, 'complete'),
            ),
            ListTile(
              leading: const Icon(Icons.star_outline_rounded),
              title: const Text('Move to Today'),
              onTap: () => Navigator.pop(sheet, 'today'),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Move to Someday'),
              onTap: () => Navigator.pop(sheet, 'someday'),
            ),
          ],
        ),
      ),
    );
    if (action == null) return;

    for (final task in _selectedTasks(provider)) {
      switch (action) {
        case 'complete':
          if (!task.isCompleted) await provider.toggleTaskCompletion(task);
          break;
        case 'today':
          await provider.moveTo(task, TaskWhen.today);
          break;
        case 'someday':
          await provider.moveTo(task, TaskWhen.someday);
          break;
      }
    }
    _endSelecting();
  }

  Future<void> _showListMenu(List<Task> tasks) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.checklist_rounded),
              title: const Text('Select…'),
              enabled: tasks.isNotEmpty,
              onTap: () => Navigator.pop(sheet, 'select'),
            ),
            ListTile(
              leading: const Icon(Icons.add_rounded),
              title: const Text('New to-do'),
              onTap: () => Navigator.pop(sheet, 'new'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'select' && tasks.isNotEmpty) {
      _startSelecting(tasks.first);
      setState(_selected.clear);
    } else if (action == 'new') {
      showQuickCapture(context, initialWhen: _whenForKind());
    }
  }

  // ---- Data ---------------------------------------------------------------

  List<Task> _tasksForKind(TaskProvider provider) {
    final open = provider.allTasks.where((task) => !task.isCompleted);
    switch (widget.kind) {
      case SystemListKind.inbox:
        return open.where((task) => task.when == TaskWhen.inbox).toList();
      case SystemListKind.today:
        return open
            .where((task) =>
                task.when == TaskWhen.today || task.when == TaskWhen.evening)
            .toList();
      case SystemListKind.upcoming:
        return open
            .where((task) =>
                task.when == TaskWhen.date && task.scheduledFor != null)
            .toList()
          ..sort((a, b) => a.scheduledFor!.compareTo(b.scheduledFor!));
      case SystemListKind.anytime:
        return open.where((task) => task.when == TaskWhen.anytime).toList();
      case SystemListKind.someday:
        return open.where((task) => task.when == TaskWhen.someday).toList();
      case SystemListKind.logbook:
        return provider.logbook;
    }
  }

  /// The agenda strip at the top of Today, built from what actually lands
  /// today: deadlines, and anything scheduled with a time of day.
  List<_AgendaEntry> _agendaForToday(TaskProvider provider) {
    final today = _dayOnly(DateTime.now());
    final entries = <_AgendaEntry>[];

    for (final task in provider.allTasks.where((task) => !task.isCompleted)) {
      final deadline = task.deadline;
      final scheduled = task.scheduledFor;
      final moment = deadline != null && _dayOnly(deadline) == today
          ? deadline
          : (scheduled != null && _dayOnly(scheduled) == today)
              ? scheduled
              : null;
      if (moment == null) continue;
      final timed = moment.hour != 0 || moment.minute != 0;
      entries.add(_AgendaEntry(
        time: timed ? DateFormat('h:mm a').format(moment) : '',
        title: task.title,
        sortKey: timed ? moment : today,
      ));
    }

    entries.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return entries.take(6).toList();
  }

  TaskWhen _whenForKind() {
    switch (widget.kind) {
      case SystemListKind.inbox:
      case SystemListKind.logbook:
        return TaskWhen.inbox;
      case SystemListKind.today:
        return TaskWhen.today;
      case SystemListKind.upcoming:
        return TaskWhen.date;
      case SystemListKind.anytime:
        return TaskWhen.anytime;
      case SystemListKind.someday:
        return TaskWhen.someday;
    }
  }

  static DateTime _dayOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static IconData _iconForKind(SystemListKind kind) {
    switch (kind) {
      case SystemListKind.inbox:
        return Icons.inbox_rounded;
      case SystemListKind.today:
        return Icons.star_rounded;
      case SystemListKind.upcoming:
        return Icons.calendar_today_rounded;
      case SystemListKind.anytime:
        return Icons.layers_rounded;
      case SystemListKind.someday:
        return Icons.archive_rounded;
      case SystemListKind.logbook:
        return Icons.check_rounded;
    }
  }

  static Color _accentForKind(SystemListKind kind) {
    switch (kind) {
      case SystemListKind.inbox:
        return TaskFlowTokens.inboxAccent;
      case SystemListKind.today:
        return TaskFlowTokens.todayAccent;
      case SystemListKind.upcoming:
        return TaskFlowTokens.upcomingAccent;
      case SystemListKind.anytime:
        return TaskFlowTokens.anytimeAccent;
      case SystemListKind.someday:
        return TaskFlowTokens.somedayAccent;
      case SystemListKind.logbook:
        return TaskFlowTokens.logbookAccent;
    }
  }

  static String _titleForKind(SystemListKind kind) {
    switch (kind) {
      case SystemListKind.inbox:
        return 'Inbox';
      case SystemListKind.today:
        return 'Today';
      case SystemListKind.upcoming:
        return 'Upcoming';
      case SystemListKind.anytime:
        return 'Anytime';
      case SystemListKind.someday:
        return 'Someday';
      case SystemListKind.logbook:
        return 'Logbook';
    }
  }
}

class _ScreenTitle extends StatelessWidget {
  const _ScreenTitle({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 25, color: color),
        const SizedBox(width: 9),
        Text(title, style: TaskFlowText.largeTitle(context.palette.textPrimary)),
      ],
    );
  }
}

/// The Upcoming nav bar's list switcher.
class _NavListChip extends StatelessWidget {
  const _NavListChip({
    required this.icon,
    required this.color,
    required this.title,
  });

  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 7),
        Text(title, style: TaskFlowText.navTitle(palette.textPrimary)),
        const SizedBox(width: 4),
        Icon(Icons.keyboard_arrow_down_rounded,
            size: 16, color: palette.textTertiary),
      ],
    );
  }
}

class _AgendaEntry {
  const _AgendaEntry({
    required this.time,
    required this.title,
    required this.sortKey,
  });

  final String time;
  final String title;
  final DateTime sortKey;
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.entries});

  final List<_AgendaEntry> entries;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.groupedFill,
        borderRadius: BorderRadius.circular(TaskFlowTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 64,
                    child: Text(entry.time,
                        style: TaskFlowText.eventTime(palette.success)),
                  ),
                  Expanded(
                    child: Text(entry.title,
                        style: TaskFlowText.eventTitle(palette.textSecondary)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final today = DateTime.now();
    final label = DateUtils.isSameDay(date, today)
        ? 'Today'
        : DateUtils.isSameDay(date, today.add(const Duration(days: 1)))
            ? 'Tomorrow'
            : DateFormat('EEEE').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${date.day}',
                  style: TaskFlowText.title1(palette.textPrimary)
                      .copyWith(height: 1)),
              const SizedBox(width: 10),
              Text(label, style: TaskFlowText.dayLabel(palette.textTertiary)),
            ],
          ),
        ),
        Container(height: 1, color: palette.separator),
      ],
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.onSelectAll, required this.onDone});

  final VoidCallback onSelectAll;
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
            onTap: onSelectAll,
            child: Text('Select All',
                style: TaskFlowText.textAction(palette.accent)),
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

class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({
    required this.count,
    required this.onWhen,
    required this.onMove,
    required this.onDelete,
    required this.onMore,
  });

  final int count;
  final VoidCallback onWhen;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = count > 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(TaskFlowTokens.radiusToolbar),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: palette.toolbar,
              borderRadius:
                  BorderRadius.circular(TaskFlowTokens.radiusToolbar),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: -8,
                    offset: const Offset(0, 12)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ToolbarAction(
                    icon: Icons.calendar_today_outlined,
                    label: 'When',
                    onTap: enabled ? onWhen : null),
                _ToolbarAction(
                    icon: Icons.arrow_forward_rounded,
                    label: 'Move',
                    onTap: enabled ? onMove : null),
                _ToolbarAction(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    onTap: enabled ? onDelete : null),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: enabled ? onMore : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(Icons.more_horiz_rounded,
                        size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 7),
            Text(label, style: TaskFlowText.toolbarAction(Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text('Nothing in $title.',
            style: TaskFlowText.meta(palette.textQuaternary)
                .copyWith(fontSize: 15)),
      ),
    );
  }
}
