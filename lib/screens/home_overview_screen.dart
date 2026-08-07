import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../design/taskflow_tokens.dart';
import '../models/organization.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/tf_widgets.dart';
import 'organization_screen.dart';
import 'project_detail_screen.dart';
import 'quick_capture_sheet.dart';
import 'quick_find_sheet.dart';
import 'system_list_screen.dart';

class HomeOverviewScreen extends StatefulWidget {
  const HomeOverviewScreen({super.key});

  @override
  State<HomeOverviewScreen> createState() => _HomeOverviewScreenState();
}

class _HomeOverviewScreenState extends State<HomeOverviewScreen> {
  final Set<int> _expandedAreas = <int>{};

  void _capture() => _captureTo(TaskWhen.inbox);

  void _captureTo(TaskWhen when) {
    showQuickCapture(context, initialWhen: when);
  }

  void _openQuickFind() => showQuickFind(context);

  /// The design gives Home no chrome beyond search and the action button, so
  /// area/project management hangs off a long press rather than a toolbar.
  Future<void> _organize() async {
    final wantsProjects = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.layers_outlined),
              title: const Text('Areas'),
              onTap: () => Navigator.pop(sheet, false),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Projects'),
              onTap: () => Navigator.pop(sheet, true),
            ),
          ],
        ),
      ),
    );
    if (wantsProjects == null || !mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => OrganizationScreen(projects: wantsProjects)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<TaskProvider>();
    final lists = _systemLists(provider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _capture,
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): _capture,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: palette.surface,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                      child: _QuickFindPill(onTap: _openQuickFind),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                        children: [
                          for (final item in lists)
                            _SystemListRow(
                              data: item,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        SystemListScreen(kind: item.kind)),
                              ),
                            ),
                          Container(
                            height: 1,
                            color: palette.separator,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 18),
                          ),
                          for (final area in provider.areas)
                            _AreaBlock(
                              area: area,
                              expanded: _expandedAreas.contains(area.id),
                              onToggle: () => _toggleArea(area),
                              onLongPress: _organize,
                              projects: provider.projects
                                  .where((project) =>
                                      project.areaId == area.id &&
                                      !project.isCompleted)
                                  .toList(),
                            ),
                          if (provider.areas.isEmpty)
                            _EmptyAreasHint(onTap: _organize),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 24,
                  bottom: 30,
                  child: GestureDetector(
                    onLongPress: _organize,
                    child: TfFab(onTap: _capture),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleArea(Area area) {
    final id = area.id;
    if (id == null) return;
    setState(() {
      if (!_expandedAreas.remove(id)) _expandedAreas.add(id);
    });
  }

  List<_SystemListRowData> _systemLists(TaskProvider provider) {
    final open = provider.allTasks.where((task) => !task.isCompleted);
    final endOfToday = _endOfToday();

    final todayCount = open
        .where((task) =>
            task.when == TaskWhen.today || task.when == TaskWhen.evening)
        .length;
    final dueCount = open
        .where((task) =>
            task.deadline != null && !task.deadline!.isAfter(endOfToday))
        .length;

    // Following the design, only Inbox and Today carry counts — the rest stay
    // quiet so the column reads as navigation, not a dashboard.
    return [
      _SystemListRowData(
        kind: SystemListKind.inbox,
        title: 'Inbox',
        icon: Icons.inbox_rounded,
        color: TaskFlowTokens.inboxAccent,
        count: open.where((task) => task.when == TaskWhen.inbox).length,
      ),
      _SystemListRowData(
        kind: SystemListKind.today,
        title: 'Today',
        icon: Icons.star_rounded,
        color: TaskFlowTokens.todayAccent,
        count: todayCount,
        urgentCount: dueCount,
      ),
      const _SystemListRowData(
        kind: SystemListKind.upcoming,
        title: 'Upcoming',
        icon: Icons.calendar_today_rounded,
        color: TaskFlowTokens.upcomingAccent,
      ),
      const _SystemListRowData(
        kind: SystemListKind.anytime,
        title: 'Anytime',
        icon: Icons.layers_rounded,
        color: TaskFlowTokens.anytimeAccent,
      ),
      const _SystemListRowData(
        kind: SystemListKind.someday,
        title: 'Someday',
        icon: Icons.archive_rounded,
        color: TaskFlowTokens.somedayAccent,
      ),
      const _SystemListRowData(
        kind: SystemListKind.logbook,
        title: 'Logbook',
        icon: Icons.check_rounded,
        color: TaskFlowTokens.logbookAccent,
      ),
    ];
  }

  static DateTime _endOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
}

class _QuickFindPill extends StatelessWidget {
  const _QuickFindPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: palette.fill,
          borderRadius: BorderRadius.circular(TaskFlowTokens.radiusSm),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 17, color: palette.textTertiary),
            const SizedBox(width: 8),
            Text('Quick Find',
                style: TextStyle(
                    color: palette.textTertiary, fontSize: 16, height: 1)),
          ],
        ),
      ),
    );
  }
}

class _SystemListRowData {
  const _SystemListRowData({
    required this.kind,
    required this.title,
    required this.icon,
    required this.color,
    this.count = 0,
    this.urgentCount = 0,
  });

  final SystemListKind kind;
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final int urgentCount;
}

class _SystemListRow extends StatelessWidget {
  const _SystemListRow({required this.data, required this.onTap});

  final _SystemListRowData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
        child: Row(
          children: [
            TfSystemIcon(icon: data.icon, color: data.color),
            const SizedBox(width: 13),
            Expanded(
              child: Text(data.title,
                  style: TaskFlowText.listTitle(palette.textPrimary)),
            ),
            if (data.urgentCount > 0) ...[
              _UrgentBadge(value: data.urgentCount),
              const SizedBox(width: 9),
            ],
            if (data.count > 0)
              Text('${data.count}',
                  style: TextStyle(
                      color: palette.textTertiary, fontSize: 16, height: 1)),
          ],
        ),
      ),
    );
  }
}

class _UrgentBadge extends StatelessWidget {
  const _UrgentBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 21),
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.palette.danger,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text('$value',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _AreaBlock extends StatelessWidget {
  const _AreaBlock({
    required this.area,
    required this.expanded,
    required this.onToggle,
    required this.onLongPress,
    required this.projects,
  });

  final Area area;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggle,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 11, 4, 7),
            child: Row(
              children: [
                Icon(Icons.layers_outlined,
                    size: 18, color: palette.textTertiary),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(area.title,
                      style: TaskFlowText.areaTitle(palette.textPrimary)),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: palette.controlBorder),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final project in projects)
                      _ProjectRow(project: project),
                    if (projects.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 2, 4, 8),
                        child: Text('No projects yet.',
                            style: TaskFlowText.meta(palette.textQuaternary)),
                      ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<TaskProvider>();
    final tasks = provider.allTasks
        .where((task) => int.tryParse(task.projectId ?? '') == project.id);
    final total = tasks.length;
    final done = tasks.where((task) => task.isCompleted).length;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 4, 8),
        child: Row(
          children: [
            TfProjectRing(progress: total == 0 ? 0 : done / total),
            const SizedBox(width: 13),
            Expanded(
              child: Text(project.title,
                  style: TaskFlowText.projectTitle(palette.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAreasHint extends StatelessWidget {
  const _EmptyAreasHint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.add_rounded, size: 17, color: palette.accent),
            const SizedBox(width: 12),
            Text('New Area',
                style: TaskFlowText.projectTitle(palette.accent)),
          ],
        ),
      ),
    );
  }
}
