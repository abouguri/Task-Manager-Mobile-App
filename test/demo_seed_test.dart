import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/services/demo_seed.dart';

import 'fake_task_store.dart';

void main() {
  late TaskProvider provider;

  setUp(() => provider = TaskProvider(store: FakeTaskStore()));

  test('the flag is off unless a build passes DEMO_SEED', () {
    expect(kSeedDemoData, isFalse,
        reason: 'only scripts/vercel-build.sh may turn this on');
  });

  test('fills every list the demo shows off', () async {
    await seedDemoData(provider);

    List<Task> forWhen(TaskWhen when) =>
        provider.allTasks.where((t) => t.when == when).toList();

    expect(forWhen(TaskWhen.inbox), isNotEmpty);
    expect(forWhen(TaskWhen.today), isNotEmpty);
    expect(forWhen(TaskWhen.evening), isNotEmpty,
        reason: 'Today shows a This Evening section');
    expect(forWhen(TaskWhen.date), isNotEmpty, reason: 'Upcoming');
    expect(forWhen(TaskWhen.anytime), isNotEmpty);
    expect(forWhen(TaskWhen.someday), isNotEmpty);
    expect(provider.areas, hasLength(2));
    expect(provider.projects, hasLength(4));
  });

  test('every task points at an area or project that exists', () async {
    await seedDemoData(provider);

    final areaIds = provider.areas.map((a) => '${a.id}').toSet();
    final projectIds = provider.projects.map((p) => '${p.id}').toSet();

    for (final task in provider.allTasks) {
      if (task.areaId != null) {
        expect(areaIds, contains(task.areaId), reason: '"${task.title}"');
      }
      if (task.projectId != null) {
        expect(projectIds, contains(task.projectId), reason: '"${task.title}"');
      }
    }
  });

  test('every heading used by a task is declared on its project', () async {
    await seedDemoData(provider);

    for (final task in provider.allTasks.where((t) => t.heading != null)) {
      final project = provider.projectById(int.parse(task.projectId!));
      expect(project, isNotNull, reason: '"${task.title}" has a heading');
      expect(project!.headings, contains(task.heading),
          reason: '"${task.title}" would render as unfiled');
    }
  });

  test('the demo has something to show for notes, checklists and tags',
      () async {
    await seedDemoData(provider);

    expect(provider.allTasks.where((t) => (t.description ?? '').isNotEmpty),
        isNotEmpty);
    expect(provider.allTasks.where((t) => t.checklist.isNotEmpty), isNotEmpty);
    expect(provider.allTasks.where((t) => t.tags.isNotEmpty), isNotEmpty);
    expect(provider.allTasks.where((t) => t.deadline != null), isNotEmpty,
        reason: "Today's red badge counts deadlines");
  });

  test('runs once — a second call cannot duplicate anything', () async {
    await seedDemoData(provider);
    final tasks = provider.allTasks.length;
    final projects = provider.projects.length;

    await seedDemoData(provider);

    expect(provider.allTasks, hasLength(tasks));
    expect(provider.projects, hasLength(projects));
  });

  test('leaves a store that already holds data alone', () async {
    await provider.addTask(Task(title: 'Something the user wrote'));

    await seedDemoData(provider);

    expect(provider.allTasks.single.title, 'Something the user wrote');
    expect(provider.areas, isEmpty);
  });
}
