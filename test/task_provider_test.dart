import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/organization.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';

import 'fake_task_store.dart';

void main() {
  late FakeTaskStore store;
  late TaskProvider provider;

  setUp(() {
    store = FakeTaskStore();
    provider = TaskProvider(store: store);
  });

  group('loading', () {
    test('a store that cannot open leaves the app empty rather than throwing',
        () async {
      final failing = TaskProvider(store: FakeTaskStore(failOnLoad: true));
      await failing.loadTasks();
      expect(failing.allTasks, isEmpty);
      expect(failing.areas, isEmpty);
      expect(failing.projects, isEmpty);
      expect(failing.isLoading, isFalse);
    });

    test('reads tasks, areas and projects back', () async {
      await store.insertTask(Task(title: 'Book flights'));
      await store.insertArea(const Area(title: 'Family'));
      await store.insertProject(
          const Project(title: 'Rome', headings: ['Planning']));

      await provider.loadTasks();

      expect(provider.allTasks.single.title, 'Book flights');
      expect(provider.areas.single.title, 'Family');
      expect(provider.projects.single.headings, ['Planning']);
    });
  });

  group('addTask', () {
    test('returns the stored task carrying its new id', () async {
      final stored = await provider.addTask(Task(title: 'Pack carry-on'));
      expect(stored.id, isNotNull);
      expect(provider.getTaskById(stored.id!)?.title, 'Pack carry-on');
    });

    test('persists the heading, not just the in-memory copy', () async {
      final stored = await provider.addTask(
          Task(title: 'Book flights', projectId: '1', heading: 'Planning'));
      expect(store.storedTask(stored.id!).heading, 'Planning');
    });

    test('notifies listeners', () async {
      var notified = 0;
      provider.addListener(() => notified++);
      await provider.addTask(Task(title: 'x'));
      expect(notified, greaterThan(0));
    });
  });

  group('toggleTaskCompletion', () {
    test('completing stamps completedAt, reopening clears it', () async {
      final task = await provider.addTask(Task(title: 'Finish report'));

      await provider.toggleTaskCompletion(task);
      final done = provider.getTaskById(task.id!)!;
      expect(done.isCompleted, isTrue);
      expect(done.completedAt, isNotNull);

      await provider.toggleTaskCompletion(done);
      final reopened = provider.getTaskById(task.id!)!;
      expect(reopened.isCompleted, isFalse);
      expect(reopened.completedAt, isNull,
          reason: 'a reopened task must not keep the old completion stamp');
    });

    test('a recurring task spawns its next occurrence, once', () async {
      final task = await provider.addTask(Task(
        title: 'Water the plants',
        when: TaskWhen.date,
        scheduledFor: DateTime(2026, 8, 7), // a Friday
        recurrence: 'weekly:5',
      ));

      await provider.toggleTaskCompletion(task);

      final open = provider.allTasks.where((t) => !t.isCompleted).toList();
      expect(open, hasLength(1));
      expect(open.single.title, 'Water the plants');
      expect(open.single.scheduledFor, DateTime(2026, 8, 14));
      expect(open.single.recurrence, 'weekly:5',
          reason: 'the copy must keep recurring');
    });

    test('the next occurrence starts with an unchecked checklist', () async {
      final task = await provider.addTask(Task(
        title: 'Weekly review',
        when: TaskWhen.date,
        scheduledFor: DateTime(2026, 8, 7),
        recurrence: 'weekly:5',
        checklist: const [
          ChecklistItem(title: 'Clear inbox', isCompleted: true),
        ],
      ));

      await provider.toggleTaskCompletion(task);

      final next = provider.allTasks.firstWhere((t) => !t.isCompleted);
      expect(next.checklist.single.isCompleted, isFalse);
    });

    test('a non-recurring task spawns nothing', () async {
      final task = await provider.addTask(Task(title: 'One-off'));
      await provider.toggleTaskCompletion(task);
      expect(provider.allTasks, hasLength(1));
    });
  });

  group('moveTo', () {
    test('moving to a date keeps it', () async {
      final task = await provider.addTask(Task(title: 'x'));
      await provider.moveTo(task, TaskWhen.date, date: DateTime(2026, 9, 1));

      final moved = provider.getTaskById(task.id!)!;
      expect(moved.when, TaskWhen.date);
      expect(moved.scheduledFor, DateTime(2026, 9, 1));
    });

    test('moving anywhere else drops the old date', () async {
      final task = await provider.addTask(Task(
        title: 'x',
        when: TaskWhen.date,
        scheduledFor: DateTime(2026, 9, 1),
      ));

      await provider.moveTo(task, TaskWhen.someday);

      final moved = provider.getTaskById(task.id!)!;
      expect(moved.when, TaskWhen.someday);
      expect(moved.scheduledFor, isNull,
          reason: 'a Someday task showing a date would sort into Upcoming');
    });
  });

  group('search', () {
    setUp(() async {
      await provider.addTask(Task(title: 'Book flights to Rome'));
      await provider
          .addTask(Task(title: 'Call the dentist', description: 'about Rome'));
      await provider.addTask(Task(title: 'Buy a gift', tags: ['rome']));
      await provider.addTask(Task(title: 'Unrelated'));
    });

    test('matches title, notes and tags', () {
      provider.searchTasks('rome');
      expect(provider.tasks.map((t) => t.title), hasLength(3));
    });

    test('clearing restores everything', () {
      provider.searchTasks('rome');
      provider.clearFilters();
      expect(provider.tasks, hasLength(4));
    });
  });

  group('logbook', () {
    test('holds only completed tasks, most recent first', () async {
      final first = await provider.addTask(Task(title: 'First'));
      final second = await provider.addTask(Task(title: 'Second'));
      await provider.addTask(Task(title: 'Still open'));

      await provider.toggleTaskCompletion(first);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await provider.toggleTaskCompletion(second);

      expect(provider.logbook.map((t) => t.title), ['Second', 'First']);
    });
  });

  group('projects', () {
    test('updateProject persists headings', () async {
      await provider.addProject(const Project(title: 'Rome'));
      final project = provider.projects.single;

      await provider
          .updateProject(project.copyWith(headings: ['Planning', 'Packing']));

      expect(provider.projects.single.headings, ['Planning', 'Packing']);
      expect(store.storedProject(project.id!).headings,
          ['Planning', 'Packing'],
          reason: 'headings must reach storage to survive navigation');
    });

    test('toggleProject flips completion and persists', () async {
      await provider.addProject(const Project(title: 'Rome'));
      final project = provider.projects.single;

      await provider.toggleProject(project);

      expect(provider.projects.single.isCompleted, isTrue);
      expect(store.storedProject(project.id!).isCompleted, isTrue);
    });

    test('areaById and projectById miss cleanly', () {
      expect(provider.areaById(null), isNull);
      expect(provider.areaById(99), isNull);
      expect(provider.projectById(99), isNull);
    });
  });
}
