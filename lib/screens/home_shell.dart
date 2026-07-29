import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../design/taskflow_tokens.dart';
import '../main.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/focus_now_card.dart';
import '../widgets/statistics_card.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';
import 'task_detail_screen.dart';

enum _HomeTab { today, inbox, projects, calendar, progress }

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  _HomeTab _currentTab = _HomeTab.today;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    final taskProvider = context.read<TaskProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: taskProvider.filterPriority == null,
                        onSelected: (_) {
                          setState(() => taskProvider.filterByPriority(null));
                        },
                      ),
                      FilterChip(
                        label: const Text('High'),
                        selected: taskProvider.filterPriority == 'High',
                        onSelected: (selected) {
                          setState(() => taskProvider.filterByPriority(selected ? 'High' : null));
                        },
                      ),
                      FilterChip(
                        label: const Text('Medium'),
                        selected: taskProvider.filterPriority == 'Medium',
                        onSelected: (selected) {
                          setState(() => taskProvider.filterByPriority(selected ? 'Medium' : null));
                        },
                      ),
                      FilterChip(
                        label: const Text('Low'),
                        selected: taskProvider.filterPriority == 'Low',
                        onSelected: (selected) {
                          setState(() => taskProvider.filterByPriority(selected ? 'Low' : null));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Project', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: taskProvider.filterCategory == null,
                        onSelected: (_) {
                          setState(() => taskProvider.filterByCategory(null));
                        },
                      ),
                      ...['Work', 'Personal', 'Shopping', 'Health', 'Other'].map(
                        (category) => FilterChip(
                          label: Text(category),
                          selected: taskProvider.filterCategory == category,
                          onSelected: (selected) {
                            setState(() => taskProvider.filterByCategory(selected ? category : null));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: taskProvider.filterCompleted == null,
                        onSelected: (_) {
                          setState(() => taskProvider.filterByCompletion(null));
                        },
                      ),
                      FilterChip(
                        label: const Text('Active'),
                        selected: taskProvider.filterCompleted == false,
                        onSelected: (selected) {
                          setState(() => taskProvider.filterByCompletion(selected ? false : null));
                        },
                      ),
                      FilterChip(
                        label: const Text('Completed'),
                        selected: taskProvider.filterCompleted == true,
                        onSelected: (selected) {
                          setState(() => taskProvider.filterByCompletion(selected ? true : null));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              taskProvider.clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final tabs = <Widget>[
      _TodayTab(onAddTask: _openAddTask),
      _InboxTab(onAddTask: _openAddTask),
      _ProjectsTab(onAddTask: _openAddTask),
      _CalendarTab(onAddTask: _openAddTask),
      const _ProgressTab(),
    ];

    final title = switch (_currentTab) {
      _HomeTab.today => 'Today',
      _HomeTab.inbox => 'Inbox',
      _HomeTab.projects => 'Projects',
      _HomeTab.calendar => 'Calendar',
      _HomeTab.progress => 'Progress',
    };

    final subtitle = switch (_currentTab) {
      _HomeTab.today => 'What should happen next?',
      _HomeTab.inbox => 'Captured and waiting',
      _HomeTab.projects => 'Grouped by outcome',
      _HomeTab.calendar => 'Plan your time',
      _HomeTab.progress => 'Stay oriented, not obsessed',
    };

    final showInitialLoading = taskProvider.isLoading && taskProvider.tasks.isEmpty;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 20,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search tasks, notes, tags',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  hintStyle: theme.textTheme.bodyMedium,
                ),
                onChanged: (value) => context.read<TaskProvider>().searchTasks(value),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  context.read<TaskProvider>().searchTasks('');
                }
                _isSearching = !_isSearching;
              });
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              } else if (value == 'theme') {
                context.read<ThemeProvider>().toggleTheme();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'theme', child: Text('Toggle theme')),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: showInitialLoading
          ? const _LoadingState()
          : IndexedStack(index: _currentTab.index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab.index,
        onDestinationSelected: (index) {
          setState(() {
            _currentTab = _HomeTab.values[index];
            _isSearching = false;
            _searchController.clear();
            context.read<TaskProvider>().searchTasks('');
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today_rounded), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox_rounded), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder_rounded), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.trending_up_outlined), selectedIcon: Icon(Icons.trending_up_rounded), label: 'Progress'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }

  void _openAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
    );
  }
}

class _TodayTab extends StatelessWidget {
  const _TodayTab({required this.onAddTask});

  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;

    if (tasks.isEmpty) {
      return _EmptyState(
        icon: Icons.task_alt_rounded,
        title: taskProvider.searchQuery.isNotEmpty || taskProvider.filterPriority != null || taskProvider.filterCategory != null || taskProvider.filterCompleted != null
            ? 'No matching tasks'
            : 'Start with one thing',
        message: taskProvider.searchQuery.isNotEmpty || taskProvider.filterPriority != null || taskProvider.filterCategory != null || taskProvider.filterCompleted != null
            ? 'Try a different search or clear the filters.'
            : 'Capture a task and TaskFlow will help shape the rest.',
        actionLabel: 'Add Task',
        onAction: onAddTask,
      );
    }

    return RefreshIndicator(
      onRefresh: () => taskProvider.loadTasks(),
      color: Theme.of(context).colorScheme.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
        children: [
          const FocusNowCard(),
          const StatisticsCard(),
          for (final task in tasks) TaskCard(task: task),
        ],
      ),
    );
  }
}

class _InboxTab extends StatelessWidget {
  const _InboxTab({required this.onAddTask});

  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks.where((task) => !task.isCompleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (tasks.isEmpty) {
      return _EmptyState(
        icon: Icons.inbox_rounded,
        title: 'Inbox is clear',
        message: 'New tasks land here first, ready for quick capture and triage.',
        actionLabel: 'Capture task',
        onAction: onAddTask,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        _SectionCard(
          title: 'Captured',
          subtitle: 'Newest first',
          trailing: '${tasks.length}',
          child: Column(
            children: [
              for (final task in tasks) _MiniTaskRow(task: task),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab({required this.onAddTask});

  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    const categories = ['Work', 'Personal', 'Shopping', 'Health', 'Other'];
    final grouped = <String, List<Task>>{
      for (final category in categories)
        category: tasks.where((task) => task.category == category).toList(),
    };

    final hasAny = grouped.values.any((list) => list.isNotEmpty);
    if (!hasAny) {
      return _EmptyState(
        icon: Icons.folder_rounded,
        title: 'No projects yet',
        message: 'Projects appear automatically when tasks start belonging together.',
        actionLabel: 'Add task',
        onAction: onAddTask,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        for (final entry in grouped.entries)
          if (entry.value.isNotEmpty)
            _SectionCard(
              title: entry.key,
              subtitle: '${entry.value.length} task${entry.value.length == 1 ? '' : 's'}',
              trailing: 'Project',
              child: Column(
                children: [
                  for (final task in entry.value.take(4)) _MiniTaskRow(task: task),
                  if (entry.value.length > 4)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${entry.value.length - 4} more',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
      ],
    );
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab({required this.onAddTask});

  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    List<Task> bucket(bool Function(Task task) test) => tasks.where(test).toList();

    final groups = <String, List<Task>>{
      'Overdue': bucket((task) => task.dueDate != null && DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day).isBefore(today)),
      'Today': bucket((task) => task.dueDate != null && DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day) == today),
      'Tomorrow': bucket((task) => task.dueDate != null && DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day) == tomorrow),
      'This week': bucket((task) {
        if (task.dueDate == null) return false;
        final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        return dueDate.isAfter(tomorrow) && !dueDate.isAfter(nextWeek);
      }),
      'Later': bucket((task) {
        if (task.dueDate == null) return false;
        final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        return dueDate.isAfter(nextWeek);
      }),
      'No date': bucket((task) => task.dueDate == null),
    };

    final hasAny = groups.values.any((list) => list.isNotEmpty);
    if (!hasAny) {
      return _EmptyState(
        icon: Icons.calendar_month_rounded,
        title: 'Nothing scheduled',
        message: 'Add due dates to see your plan laid out by time.',
        actionLabel: 'Add task',
        onAction: onAddTask,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        for (final entry in groups.entries)
          if (entry.value.isNotEmpty)
            _SectionCard(
              title: entry.key,
              subtitle: '${entry.value.length} task${entry.value.length == 1 ? '' : 's'}',
              trailing: entry.key == 'Today' ? 'Now' : '',
              child: Column(
                children: [
                  for (final task in entry.value) _MiniTaskRow(task: task),
                ],
              ),
            ),
      ],
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final completed = taskProvider.tasks.where((task) => task.isCompleted).length;
    final pending = taskProvider.tasks.where((task) => !task.isCompleted).length;
    final dueToday = taskProvider.tasks.where((task) {
      if (task.dueDate == null) return false;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day) == today;
    }).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
      children: [
        const StatisticsCard(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionCard(
            title: 'Quick review',
            subtitle: 'What needs attention next',
            trailing: 'Today',
            child: Column(
              children: [
                _ReviewRow(label: 'Completed', value: '$completed'),
                _ReviewRow(label: 'Pending', value: '$pending'),
                _ReviewRow(label: 'Due today', value: '$dueToday'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.subtitle, required this.trailing, required this.child});

  final String title;
  final String subtitle;
  final String trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(TaskFlowTokens.radiusLg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              if (trailing.isNotEmpty)
                Text(trailing, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MiniTaskRow extends StatelessWidget {
  const _MiniTaskRow({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final dateText = task.dueDate == null ? 'No date' : DateFormat('EEE, MMM d').format(task.dueDate!);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(taskId: task.id!)),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.65),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${task.category} • $dateText • ${task.effortMinutes}m',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: TaskFlowTokens.primarySoft,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(icon, size: 42, color: TaskFlowTokens.primary),
              ),
              const SizedBox(height: 24),
              Text(title, style: textTheme.displayMedium, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 144,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(TaskFlowTokens.radiusLg),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < 4; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 86,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(TaskFlowTokens.radiusLg),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(height: 14, width: double.infinity, color: Colors.black12),
                        const SizedBox(height: 8),
                        Container(height: 10, width: 180, color: Colors.black12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}