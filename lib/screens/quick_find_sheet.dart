import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design/taskflow_tokens.dart';
import '../models/organization.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'project_detail_screen.dart';
import 'system_list_screen.dart';

/// Opens Quick Find over the current screen. The list underneath stays visible
/// through the scrim so the panel reads as a lens, not a new place.
Future<void> showQuickFind(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Quick Find',
    barrierColor: context.palette.scrim,
    transitionDuration: const Duration(milliseconds: 180),
    // showGeneralDialog builds outside any Material ancestor, which would
    // leave every Text with the framework's fallback underline.
    pageBuilder: (_, __, ___) => const Material(
      type: MaterialType.transparency,
      child: QuickFindSheet(),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.03), end: Offset.zero)
              .animate(curved),
          child: child,
        ),
      );
    },
  );
}

class QuickFindSheet extends StatefulWidget {
  const QuickFindSheet({super.key});

  @override
  State<QuickFindSheet> createState() => _QuickFindSheetState();
}

class _QuickFindSheetState extends State<QuickFindSheet> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<TaskProvider>();
    final query = _query.text.trim().toLowerCase();
    final results = query.isEmpty
        ? _recents()
        : _search(provider, query).take(6).toList();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(TaskFlowTokens.radiusLg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: palette.surface.withOpacity(0.96),
                  borderRadius:
                      BorderRadius.circular(TaskFlowTokens.radiusLg),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                    BoxShadow(
                        color: Colors.black.withOpacity(0.38),
                        blurRadius: 48,
                        spreadRadius: -14,
                        offset: const Offset(0, 24)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SearchField(
                      controller: _query,
                      onChanged: (_) => setState(() {}),
                      onClose: () => Navigator.pop(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                      child: Text(
                        query.isEmpty ? 'Recent' : 'Results',
                        style: TextStyle(
                            color: palette.textTertiary,
                            fontSize: 13,
                            height: 1,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: palette.separator,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          for (final result in results)
                            _ResultRow(
                              result: result,
                              onTap: () => _open(result),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: Text(
                        query.isEmpty
                            ? 'Quickly switch lists, find to-dos, search for tags…'
                            : results.isEmpty
                                ? 'Nothing matches “${_query.text.trim()}”.'
                                : 'Quickly switch lists, find to-dos, search for tags…',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: palette.textQuaternary,
                            fontSize: 12.5,
                            height: 1.45),
                      ),
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

  List<_FindResult> _recents() => const [
        _FindResult(
            title: 'Inbox',
            subtitle: 'List',
            dot: TaskFlowTokens.inboxAccent,
            kind: SystemListKind.inbox),
        _FindResult(
            title: 'Today',
            subtitle: 'List',
            dot: TaskFlowTokens.todayAccent,
            kind: SystemListKind.today),
        _FindResult(
            title: 'Upcoming',
            subtitle: 'List',
            dot: TaskFlowTokens.upcomingAccent,
            kind: SystemListKind.upcoming),
        _FindResult(
            title: 'Anytime',
            subtitle: 'List',
            dot: TaskFlowTokens.anytimeAccent,
            kind: SystemListKind.anytime),
        _FindResult(
            title: 'Logbook',
            subtitle: 'List',
            dot: TaskFlowTokens.logbookAccent,
            kind: SystemListKind.logbook),
      ];

  List<_FindResult> _search(TaskProvider provider, String query) {
    final results = <_FindResult>[];

    for (final recent in _recents()) {
      if (recent.title.toLowerCase().contains(query)) results.add(recent);
    }

    for (final project in provider.projects) {
      if (!project.title.toLowerCase().contains(query)) continue;
      final area = provider.areaById(project.areaId);
      results.add(_FindResult(
        title: project.title,
        subtitle: area?.title ?? 'Project',
        dot: TaskFlowTokens.primary,
        project: project,
      ));
    }

    for (final task in provider.allTasks) {
      final matches = task.title.toLowerCase().contains(query) ||
          task.tags.any((tag) => tag.toLowerCase().contains(query));
      if (!matches) continue;
      final project =
          provider.projectById(int.tryParse(task.projectId ?? ''));
      results.add(_FindResult(
        title: task.title,
        subtitle: project?.title ?? _listLabel(task.when),
        dot: TaskFlowTokens.controlBorder,
        task: task,
      ));
    }

    return results;
  }

  void _open(_FindResult result) {
    Navigator.pop(context);
    final project = result.project;
    if (project != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)));
      return;
    }
    final kind = result.kind ?? _kindFor(result.task?.when ?? TaskWhen.inbox);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SystemListScreen(kind: kind, focusTaskId: result.task?.id),
      ),
    );
  }

  static SystemListKind _kindFor(TaskWhen when) {
    switch (when) {
      case TaskWhen.inbox:
        return SystemListKind.inbox;
      case TaskWhen.today:
      case TaskWhen.evening:
        return SystemListKind.today;
      case TaskWhen.date:
        return SystemListKind.upcoming;
      case TaskWhen.anytime:
        return SystemListKind.anytime;
      case TaskWhen.someday:
        return SystemListKind.someday;
    }
  }

  static String _listLabel(TaskWhen when) {
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: palette.fill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      size: 16, color: palette.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15.5,
                          height: 1.2),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Quick Find',
                        hintStyle: TextStyle(
                            color: palette.textTertiary,
                            fontSize: 15.5,
                            height: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: Container(
              width: 28,
              height: 28,
              decoration:
                  BoxDecoration(color: palette.fill, shape: BoxShape.circle),
              child: Icon(Icons.close_rounded,
                  size: 15, color: palette.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FindResult {
  const _FindResult({
    required this.title,
    required this.subtitle,
    required this.dot,
    this.kind,
    this.project,
    this.task,
  });

  final String title;
  final String subtitle;
  final Color dot;
  final SystemListKind? kind;
  final Project? project;
  final Task? task;
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result, required this.onTap});

  final _FindResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: result.dot,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(result.title,
                      style: TaskFlowText.resultTitle(palette.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(result.subtitle,
                      style: TextStyle(
                          color: palette.textQuaternary,
                          fontSize: 12,
                          height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
