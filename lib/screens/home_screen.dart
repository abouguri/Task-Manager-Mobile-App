import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../design/taskflow_tokens.dart';
import '../providers/task_provider.dart';
import '../widgets/focus_now_card.dart';
import '../widgets/task_card.dart';
import '../widgets/statistics_card.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';
import '../main.dart';

/// Home screen displaying the list of tasks with search and filter capabilities
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Show filter dialog
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
                  // Priority filter
                  const Text(
                    'Priority',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: taskProvider.filterPriority == null,
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByPriority(null);
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('High'),
                        selected: taskProvider.filterPriority == 'High',
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByPriority(selected ? 'High' : null);
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Medium'),
                        selected: taskProvider.filterPriority == 'Medium',
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByPriority(selected ? 'Medium' : null);
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Low'),
                        selected: taskProvider.filterPriority == 'Low',
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByPriority(selected ? 'Low' : null);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Category filter
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: taskProvider.filterCategory == null,
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByCategory(null);
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Work'),
                        selected: taskProvider.filterCategory == 'Work',
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByCategory(selected ? 'Work' : null);
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Personal'),
                        selected: taskProvider.filterCategory == 'Personal',
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByCategory(selected ? 'Personal' : null);
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Shopping'),
                        selected: taskProvider.filterCategory == 'Shopping',
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByCategory(selected ? 'Shopping' : null);
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Health'),
                        selected: taskProvider.filterCategory == 'Health',
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByCategory(selected ? 'Health' : null);
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Other'),
                        selected: taskProvider.filterCategory == 'Other',
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByCategory(selected ? 'Other' : null);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Status filter
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: taskProvider.filterCompleted == null,
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByCompletion(null);
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Active'),
                        selected: taskProvider.filterCompleted == false,
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByCompletion(selected ? false : null);
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Completed'),
                        selected: taskProvider.filterCompleted == true,
                        onSelected: (selected) {
                          setState(() {
                            taskProvider.filterByCompletion(selected ? true : null);
                          });
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
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
                  hintStyle: textTheme.bodyMedium,
                ),
                onChanged: (value) {
                  context.read<TaskProvider>().searchTasks(value);
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TaskFlow', style: textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    'What should happen next?',
                    style: textTheme.bodyMedium,
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              } else if (value == 'theme') {
                context.read<ThemeProvider>().toggleTheme();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'theme', child: Text('Toggle theme')),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (taskProvider.tasks.isEmpty) {
            return _EmptyState(
              onAddTask: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditTaskScreen(),
                  ),
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => taskProvider.loadTasks(),
            color: theme.colorScheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
              itemCount: taskProvider.tasks.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const FocusNowCard();
                }

                if (index == 1) {
                  return const StatisticsCard();
                }

                final task = taskProvider.tasks[index - 2];
                return TaskCard(task: task);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTaskScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddTask});

  final VoidCallback onAddTask;

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
                child: const Icon(Icons.task_alt_rounded, size: 42, color: TaskFlowTokens.primary),
              ),
              const SizedBox(height: 24),
              Text('Start with one thing', style: textTheme.displayMedium, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Capture a task and TaskFlow will help shape the rest.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
