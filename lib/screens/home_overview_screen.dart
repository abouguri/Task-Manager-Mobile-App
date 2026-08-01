import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/organization.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';
import 'organization_screen.dart';
import 'quick_capture_sheet.dart';
import 'system_list_screen.dart';

class HomeOverviewScreen extends StatefulWidget {
  const HomeOverviewScreen({super.key});

  @override
  State<HomeOverviewScreen> createState() => _HomeOverviewScreenState();
}

class _HomeOverviewScreenState extends State<HomeOverviewScreen> {
  final TextEditingController _search = TextEditingController();
  final Set<int> _expandedAreas = <int>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _capture() => _captureTo(TaskWhen.inbox);

  void _captureTo(TaskWhen when) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickCaptureSheet(initialWhen: when),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    final lists = [
      _SystemListRowData(
        kind: SystemListKind.inbox,
        title: 'Inbox',
        icon: Icons.inbox_outlined,
        color: const Color(0xFF5A7DFF),
        totalCount: provider.allTasks.where((task) => task.when == TaskWhen.inbox && !task.isCompleted).length,
        urgentCount: provider.allTasks.where((task) => !task.isCompleted && (task.when == TaskWhen.date || task.deadline != null)).length,
      ),
      _SystemListRowData(
        kind: SystemListKind.today,
        title: 'Today',
        icon: Icons.star_rounded,
        color: const Color(0xFFEE8A3A),
        totalCount: provider.allTasks.where((task) => !task.isCompleted && (task.when == TaskWhen.today || task.when == TaskWhen.evening)).length,
        urgentCount: provider.allTasks.where((task) => !task.isCompleted && (task.when == TaskWhen.today || task.when == TaskWhen.evening || task.deadline != null)).length,
      ),
      _SystemListRowData(
        kind: SystemListKind.upcoming,
        title: 'Upcoming',
        icon: Icons.calendar_month_outlined,
        color: const Color(0xFF47A57A),
        totalCount: provider.allTasks.where((task) => !task.isCompleted && (task.when == TaskWhen.date || task.scheduledFor != null)).length,
        urgentCount: provider.allTasks.where((task) => !task.isCompleted && task.deadline != null).length,
      ),
      _SystemListRowData(
        kind: SystemListKind.anytime,
        title: 'Anytime',
        icon: Icons.check_circle_outline,
        color: const Color(0xFF8B8F97),
        totalCount: provider.allTasks.where((task) => task.when == TaskWhen.anytime && !task.isCompleted).length,
        urgentCount: 0,
      ),
      _SystemListRowData(
        kind: SystemListKind.someday,
        title: 'Someday',
        icon: Icons.lightbulb_outline,
        color: const Color(0xFF8C6D44),
        totalCount: provider.allTasks.where((task) => task.when == TaskWhen.someday && !task.isCompleted).length,
        urgentCount: 0,
      ),
      _SystemListRowData(
        kind: SystemListKind.logbook,
        title: 'Logbook',
        icon: Icons.history_rounded,
        color: const Color(0xFF6F7582),
        totalCount: provider.allTasks.where((task) => task.isCompleted).length,
        urgentCount: 0,
      ),
    ];

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _capture,
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): _capture,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 88),
              children: [
                _TopSearchBar(controller: _search, onChanged: provider.searchTasks),
                const SizedBox(height: 18),
                for (final item in lists) ...[
                  _SystemListRow(
                    data: item,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SystemListScreen(kind: item.kind)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                const Divider(height: 24),
                _AreasHeader(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrganizationScreen(projects: false)),
                  ),
                ),
                const SizedBox(height: 10),
                for (final area in provider.areas) ...[
                  _AreaBlock(
                    area: area,
                    expanded: _expandedAreas.contains(area.id),
                    onToggle: () => setState(() {
                      if (_expandedAreas.contains(area.id)) {
                        _expandedAreas.remove(area.id);
                      } else {
                        _expandedAreas.add(area.id!);
                      }
                    }),
                    children: _expandedAreas.contains(area.id) ? _buildAreaChildren(context, provider, area) : const [],
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          floatingActionButton: _QuickAddFab(onCapture: _capture, onCaptureTo: _captureTo),
        ),
      ),
    );
  }

  List<Widget> _buildAreaChildren(BuildContext context, TaskProvider provider, Area area) {
    final areaId = area.id;
    final widgets = <Widget>[];

    for (final project in provider.projects.where((project) => project.areaId == areaId)) {
      widgets.add(_ProjectRow(project: project, area: area));
    }

    for (final task in provider.allTasks.where((task) => !task.isCompleted && int.tryParse(task.areaId ?? '') == areaId && task.projectId == null)) {
      widgets.add(_StandaloneTaskRow(task: task));
    }

    return widgets;
  }
}

class _TopSearchBar extends StatelessWidget {
  const _TopSearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Quick Find',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.55),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.4),
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
    required this.totalCount,
    required this.urgentCount,
  });

  final SystemListKind kind;
  final String title;
  final IconData icon;
  final Color color;
  final int totalCount;
  final int urgentCount;
}

class _SystemListRow extends StatelessWidget {
  const _SystemListRow({required this.data, required this.onTap});

  final _SystemListRowData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            _RoundedSquareIcon(color: data.color, icon: data.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            _CountBadge(value: data.totalCount.toString(), urgent: false),
            if (data.urgentCount > 0) ...[
              const SizedBox(width: 8),
              _CountBadge(value: data.urgentCount.toString(), urgent: true),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoundedSquareIcon extends StatelessWidget {
  const _RoundedSquareIcon({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.value, required this.urgent});

  final String value;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFD84B4B).withOpacity(0.14) : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: urgent ? const Color(0xFFD84B4B) : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _AreasHeader extends StatelessWidget {
  const _AreasHeader({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.folder_zip_outlined, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Areas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Icon(Icons.expand_more_rounded, color: Theme.of(context).colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class _AreaBlock extends StatelessWidget {
  const _AreaBlock({required this.area, required this.expanded, required this.onToggle, required this.children});

  final Area area;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: Color(area.accentColor), shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(area.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.outline),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.only(left: 20, top: 4, bottom: 8),
                  child: Column(children: children),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({required this.project, required this.area});

  final Project project;
  final Area area;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final total = provider.allTasks.where((task) => int.tryParse(task.projectId ?? '') == project.id && !task.isCompleted).length;
    final completed = provider.allTasks.where((task) => int.tryParse(task.projectId ?? '') == project.id && task.isCompleted).length;
    final progress = total + completed == 0 ? 0.0 : completed / (total + completed);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _ProjectRingIcon(progress: progress, color: Color(area.accentColor)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(project.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
          if (total > 0) _CountBadge(value: '$total', urgent: false),
        ],
      ),
    );
  }
}

class _StandaloneTaskRow extends StatelessWidget {
  const _StandaloneTaskRow({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
          const SizedBox(width: 10),
          Expanded(child: Text(task.title, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _ProjectRingIcon extends StatelessWidget {
  const _ProjectRingIcon({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 2.2,
            backgroundColor: color.withOpacity(0.16),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: progress >= 1 ? color : Colors.transparent, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _QuickAddFab extends StatelessWidget {
  const _QuickAddFab({required this.onCapture, required this.onCaptureTo});

  final VoidCallback onCapture;
  final ValueChanged<TaskWhen> onCaptureTo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          shape: const CircleBorder(),
          elevation: 2,
          child: PopupMenuButton<SystemListKind>(
            padding: EdgeInsets.zero,
            tooltip: 'Quick capture target',
            icon: const Icon(Icons.expand_less_rounded),
            onSelected: (kind) {
              switch (kind) {
                case SystemListKind.today:
                  onCaptureTo(TaskWhen.today);
                  break;
                case SystemListKind.upcoming:
                  onCaptureTo(TaskWhen.date);
                  break;
                case SystemListKind.anytime:
                  onCaptureTo(TaskWhen.anytime);
                  break;
                case SystemListKind.someday:
                  onCaptureTo(TaskWhen.someday);
                  break;
                case SystemListKind.inbox:
                case SystemListKind.logbook:
                  onCapture();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: SystemListKind.inbox, child: Text('Inbox')),
              PopupMenuItem(value: SystemListKind.today, child: Text('Today')),
              PopupMenuItem(value: SystemListKind.upcoming, child: Text('Upcoming')),
              PopupMenuItem(value: SystemListKind.anytime, child: Text('Anytime')),
              PopupMenuItem(value: SystemListKind.someday, child: Text('Someday')),
            ],
          ),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: onCapture,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}