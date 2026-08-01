import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';

enum SystemListKind { inbox, today, upcoming, anytime, someday, logbook }

class SystemListScreen extends StatelessWidget {
  const SystemListScreen({super.key, required this.kind});

  final SystemListKind kind;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = _tasksForKind(provider);
    final isToday = kind == SystemListKind.today;
    final isUpcoming = kind == SystemListKind.upcoming;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 10, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(_iconForKind(kind), size: 28),
                    const SizedBox(width: 10),
                    Text(_titleForKind(kind), style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'Nothing here yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                      children: [
                        if (isToday) _TodaySummaryBlock(tasks: tasks),
                        if (isToday) const SizedBox(height: 16),
                        if (isToday) ...[
                          ...tasks.where((task) => task.when != TaskWhen.evening).map((task) => _TaskLine(task: task)),
                          if (tasks.any((task) => task.when == TaskWhen.evening)) ...[
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                const Icon(Icons.nights_stay_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text('This Evening', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...tasks.where((task) => task.when == TaskWhen.evening).map((task) => _TaskLine(task: task)),
                          ],
                        ] else if (isUpcoming)
                          ..._buildUpcomingGroups(context, provider, tasks),
                        if (!isToday && !isUpcoming)
                          ...tasks.map((task) => _TaskLine(task: task)),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTaskScreen())),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Task> _tasksForKind(TaskProvider provider) {
    switch (kind) {
      case SystemListKind.inbox:
        return provider.allTasks.where((task) => task.when == TaskWhen.inbox && !task.isCompleted).toList();
      case SystemListKind.today:
        return provider.allTasks.where((task) => !task.isCompleted && (task.when == TaskWhen.today || task.when == TaskWhen.evening)).toList();
      case SystemListKind.upcoming:
        return provider.allTasks.where((task) => !task.isCompleted && (task.when == TaskWhen.date || task.scheduledFor != null)).toList()..sort((a, b) => (a.scheduledFor ?? DateTime.now()).compareTo(b.scheduledFor ?? DateTime.now()));
      case SystemListKind.anytime:
        return provider.allTasks.where((task) => task.when == TaskWhen.anytime && !task.isCompleted).toList();
      case SystemListKind.someday:
        return provider.allTasks.where((task) => task.when == TaskWhen.someday && !task.isCompleted).toList();
      case SystemListKind.logbook:
        return provider.logbook;
    }
  }

  Iterable<Widget> _buildUpcomingGroups(BuildContext context, TaskProvider provider, List<Task> tasks) {
    final grouped = <DateTime, List<Task>>{};
    for (final task in tasks) {
      final date = _dayOnly(task.scheduledFor ?? DateTime.now());
      grouped.putIfAbsent(date, () => <Task>[]).add(task);
    }

    final sortedDates = grouped.keys.toList()..sort();
    return [
      for (final date in sortedDates) ...[
        _UpcomingDateHeader(date: date),
        const SizedBox(height: 8),
        for (final task in grouped[date]!) _UpcomingDraggableTask(task: task, date: date),
        const SizedBox(height: 14),
      ],
    ];
  }

  DateTime _dayOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  IconData _iconForKind(SystemListKind kind) {
    switch (kind) {
      case SystemListKind.inbox:
        return Icons.inbox_outlined;
      case SystemListKind.today:
        return Icons.star_rounded;
      case SystemListKind.upcoming:
        return Icons.calendar_month_outlined;
      case SystemListKind.anytime:
        return Icons.check_circle_outline;
      case SystemListKind.someday:
        return Icons.lightbulb_outline;
      case SystemListKind.logbook:
        return Icons.history_rounded;
    }
  }

  String _titleForKind(SystemListKind kind) {
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

class _TodaySummaryBlock extends StatelessWidget {
  const _TodaySummaryBlock({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final preview = tasks.take(3).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          if (preview.isEmpty)
            Text('No scheduled items yet.', style: Theme.of(context).textTheme.bodyMedium)
          else
            for (final task in preview)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
        ],
      ),
    );
  }
}

class _TaskLine extends StatelessWidget {
  const _TaskLine({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final project = provider.projectById(int.tryParse(task.projectId ?? ''));
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  if (project != null)
                    Text(project.title, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (task.tags.isNotEmpty || task.checklist.isNotEmpty || task.description != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (task.description != null)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.notes_outlined, size: 15),
                    ),
                  if (task.checklist.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _MiniBadge(text: '${task.checklist.where((item) => item.isCompleted).length}/${task.checklist.length}'),
                    ),
                  if (task.tags.isNotEmpty)
                    _MiniBadge(text: '${task.tags.length}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _UpcomingDateHeader extends StatelessWidget {
  const _UpcomingDateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final relative = DateUtils.isSameDay(date, today)
        ? 'Today'
        : DateUtils.isSameDay(date, today.add(const Duration(days: 1)))
            ? 'Tomorrow'
            : MaterialLocalizations.of(context).formatMediumDate(date);
    return DragTarget<Task>(
      onAcceptWithDetails: (details) {
        final task = details.data;
        final scheduled = task.scheduledFor;
        final updated = task.copyWith(
          when: TaskWhen.date,
          scheduledFor: scheduled == null
              ? date
              : DateTime(date.year, date.month, date.day, scheduled.hour, scheduled.minute),
        );
        context.read<TaskProvider>().updateTask(updated);
      },
      builder: (context, candidate, rejected) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: candidate.isNotEmpty ? Theme.of(context).colorScheme.primary.withOpacity(0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${date.day}', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(relative, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UpcomingDraggableTask extends StatelessWidget {
  const _UpcomingDraggableTask({required this.task, required this.date});

  final Task task;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(blurRadius: 20, color: Color(0x22000000), offset: Offset(0, 8))],
          ),
          child: Text(task.title),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.45,
        child: _TaskLine(task: task),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: _TaskLine(task: task),
      ),
    );
  }
}