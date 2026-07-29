import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';

enum _View { inbox, today, upcoming, anytime, someday, logbook }

class HomeShell extends StatefulWidget { const HomeShell({super.key}); @override State<HomeShell> createState() => _HomeShellState(); }
class _HomeShellState extends State<HomeShell> {
  _View _view = _View.inbox;
  final _search = TextEditingController();
  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => context.read<TaskProvider>().loadTasks()); }
  @override void dispose() { _search.dispose(); super.dispose(); }
  void _capture() => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTaskScreen()));
  @override Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final items = const [(Icons.inbox_outlined, 'Inbox'), (Icons.today_outlined, 'Today'), (Icons.calendar_month_outlined, 'Upcoming'), (Icons.check_circle_outline, 'Anytime'), (Icons.lightbulb_outline, 'Someday'), (Icons.history, 'Logbook')];
    final nav = NavigationRail(selectedIndex: _view.index, labelType: NavigationRailLabelType.all, onDestinationSelected: (index) => setState(() => _view = _View.values[index]), destinations: [for (final item in items) NavigationRailDestination(icon: Icon(item.$1), label: Text(item.$2))]);
    return Scaffold(
      body: SafeArea(child: Row(children: [if (wide) nav, Expanded(child: Column(children: [_topBar(), Expanded(child: _TaskList(view: _view, onCapture: _capture))]))])),
      bottomNavigationBar: wide ? null : NavigationBar(selectedIndex: _view.index, onDestinationSelected: (i) => setState(() => _view = _View.values[i]), destinations: [for (final item in items) NavigationDestination(icon: Icon(item.$1), label: item.$2)]),
      floatingActionButton: FloatingActionButton.small(onPressed: _capture, tooltip: 'Quick capture', child: const Icon(Icons.add)),
    );
  }
  Widget _topBar() => Padding(padding: const EdgeInsets.fromLTRB(24, 20, 18, 8), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_title, style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 2), Text(_subtitle, style: Theme.of(context).textTheme.bodyMedium)])), SizedBox(width: 210, child: TextField(controller: _search, onChanged: context.read<TaskProvider>().searchTasks, decoration: const InputDecoration(hintText: 'Search', prefixIcon: Icon(Icons.search), isDense: true)))]));
  String get _title => ['Inbox', 'Today', 'Upcoming', 'Anytime', 'Someday', 'Logbook'][_view.index];
  String get _subtitle => switch (_view) { _View.inbox => 'Everything starts here.', _View.today => 'A short list for today.', _View.upcoming => 'A glance ahead.', _View.anytime => 'Ready whenever you are.', _View.someday => 'Ideas, safely out of the way.', _View.logbook => 'What you’ve finished.' };
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.view, required this.onCapture}); final _View view; final VoidCallback onCapture;
  @override Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    if (provider.isLoading && provider.allTasks.isEmpty) return const Center(child: CircularProgressIndicator());
    final tasks = switch (view) { _View.inbox => provider.forWhen(TaskWhen.inbox), _View.today => [...provider.forWhen(TaskWhen.today), ...provider.forWhen(TaskWhen.evening)], _View.upcoming => provider.allTasks.where((t) => !t.isCompleted && (t.when == TaskWhen.date || t.scheduledFor != null)).toList()..sort((a,b) => a.scheduledFor!.compareTo(b.scheduledFor!)), _View.anytime => provider.forWhen(TaskWhen.anytime), _View.someday => provider.forWhen(TaskWhen.someday), _View.logbook => provider.logbook };
    if (tasks.isEmpty) return _Empty(view: view, onCapture: onCapture);
    return ListView.builder(padding: const EdgeInsets.fromLTRB(24, 8, 24, 96), itemCount: tasks.length, itemBuilder: (context, index) { final task = tasks[index]; final previous = index == 0 ? null : tasks[index - 1]; final showDate = view == _View.upcoming && (previous?.scheduledFor == null || !DateUtils.isSameDay(previous!.scheduledFor, task.scheduledFor)); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (showDate) Padding(padding: const EdgeInsets.only(top: 18, bottom: 6), child: Text(DateFormat('EEEE, MMMM d').format(task.scheduledFor!), style: Theme.of(context).textTheme.labelLarge)), _TaskRow(task: task)]); });
  }
}
class _TaskRow extends StatelessWidget { const _TaskRow({required this.task}); final Task task;
  @override Widget build(BuildContext context) => Dismissible(key: ValueKey(task.id), direction: task.isCompleted ? DismissDirection.none : DismissDirection.startToEnd, background: Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 18), color: Theme.of(context).colorScheme.primary, child: const Icon(Icons.check, color: Colors.white)), confirmDismiss: (_) async { await context.read<TaskProvider>().toggleTaskCompletion(task); return false; }, child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task))), child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Row(children: [GestureDetector(onTap: () => context.read<TaskProvider>().toggleTaskCompletion(task), child: AnimatedContainer(duration: const Duration(milliseconds: 180), width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, color: task.isCompleted ? Theme.of(context).colorScheme.primary : Colors.transparent, border: Border.all(color: Theme.of(context).dividerColor, width: 1.5)), child: task.isCompleted ? const Icon(Icons.check, size: 15, color: Colors.white) : null)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(task.title, style: TextStyle(fontSize: 16, decoration: task.isCompleted ? TextDecoration.lineThrough : null, color: task.isCompleted ? Theme.of(context).colorScheme.outline : null)), if (task.description != null) Padding(padding: const EdgeInsets.only(top: 3), child: Text(task.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium))])), if (task.when == TaskWhen.evening) const Icon(Icons.nights_stay_outlined, size: 17)])))); }
class _Empty extends StatelessWidget { const _Empty({required this.view, required this.onCapture}); final _View view; final VoidCallback onCapture; @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(view == _View.inbox ? Icons.inbox_outlined : Icons.check_circle_outline, size: 42, color: Theme.of(context).colorScheme.outline), const SizedBox(height: 16), Text(view == _View.inbox ? 'Your Inbox is clear.' : 'Nothing here right now.', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 6), Text(view == _View.inbox ? 'Capture a thought before it gets away.' : 'A little empty space is a good thing.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium), if (view == _View.inbox) TextButton(onPressed: onCapture, child: const Text('Capture a task'))]))); }
