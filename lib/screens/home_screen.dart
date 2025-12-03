import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                onChanged: (value) {
                  context.read<TaskProvider>().searchTasks(value);
                },
              )
            : const Text('Tasks'),
        actions: [
          // Theme toggle button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isDark = themeProvider.themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
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
          const SizedBox(width: 8),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 80,
                      color: const Color(0xFF6C63FF).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No tasks yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap the + button to create your first task',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => taskProvider.loadTasks(),
            color: const Color(0xFF6C63FF),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
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
