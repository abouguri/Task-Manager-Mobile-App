import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';

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
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  context.read<TaskProvider>().searchTasks(value);
                },
              )
            : const Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  context.read<TaskProvider>().searchTasks('');
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
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
                  Icon(
                    Icons.task_alt,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet!',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first task',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => taskProvider.loadTasks(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () {
                    // Navigate to task detail screen (will be implemented)
                    Navigator.pushNamed(
                      context,
                      '/task-detail',
                      arguments: task.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
