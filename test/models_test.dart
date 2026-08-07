import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/organization.dart';
import 'package:task_manager/models/task.dart';

void main() {
  group('Task serialisation', () {
    test('round-trips every field the redesign writes', () {
      final task = Task(
        id: 7,
        title: 'Pack carry-on',
        description: 'Take the small gray messenger bag.',
        tags: ['packing', 'travel'],
        checklist: const [
          ChecklistItem(title: 'Passport', isCompleted: true),
          ChecklistItem(title: 'iPad'),
        ],
        when: TaskWhen.date,
        scheduledFor: DateTime(2026, 8, 12, 9, 30),
        deadline: DateTime(2026, 8, 15),
        projectId: '3',
        areaId: '1',
        heading: 'Get packed',
        recurrence: 'weekly:5',
        createdAt: DateTime(2026, 8, 1),
      );

      final back = Task.fromMap(task.toMap());

      expect(back.title, task.title);
      expect(back.description, task.description);
      expect(back.tags, task.tags);
      expect(back.checklist.map((c) => c.title), ['Passport', 'iPad']);
      expect(back.checklist.first.isCompleted, isTrue);
      expect(back.checklist.last.isCompleted, isFalse);
      expect(back.when, TaskWhen.date);
      expect(back.scheduledFor, task.scheduledFor);
      expect(back.deadline, task.deadline);
      expect(back.projectId, '3');
      expect(back.areaId, '1');
      expect(back.heading, 'Get packed');
      expect(back.recurrence, 'weekly:5');
      expect(back.createdAt, task.createdAt);
    });

    test('a task with no heading stays unfiled', () {
      final back = Task.fromMap(Task(title: 'Loose').toMap());
      expect(back.heading, isNull);
    });

    test('clearHeading removes it, plain copyWith does not', () {
      final task = Task(title: 'x', heading: 'Planning');
      expect(task.copyWith(title: 'y').heading, 'Planning');
      expect(task.copyWith(clearHeading: true).heading, isNull);
    });

    test('a pre-v4 row infers when from its due date', () {
      // Rows written before whenValue existed carry only dueDate.
      final scheduled = Task.fromMap({
        'id': 1,
        'title': 'Old scheduled task',
        'dueDate': DateTime(2026, 9, 1).toIso8601String(),
        'createdAt': DateTime(2026, 8, 1).toIso8601String(),
      });
      expect(scheduled.when, TaskWhen.date);
      expect(scheduled.scheduledFor, DateTime(2026, 9, 1));

      final loose = Task.fromMap({
        'id': 2,
        'title': 'Old loose task',
        'createdAt': DateTime(2026, 8, 1).toIso8601String(),
      });
      expect(loose.when, TaskWhen.inbox);
    });

    test('legacy category becomes a project, except its placeholders', () {
      Task from(String category) => Task.fromMap({
            'title': 't',
            'category': category,
            'createdAt': DateTime(2026, 8, 1).toIso8601String(),
          });
      expect(from('Work').projectId, 'Work');
      expect(from('Inbox').projectId, isNull);
      expect(from('Personal').projectId, isNull);
    });

    test('malformed stored checklist degrades to empty, not a crash', () {
      final back = Task.fromMap({
        'title': 't',
        'checklist': 'not json',
        'createdAt': DateTime(2026, 8, 1).toIso8601String(),
      });
      expect(back.checklist, isEmpty);
    });
  });

  group('Project headings', () {
    test('round-trip preserves order', () {
      final project = Project(
        id: 1,
        title: 'Vacation in Rome',
        areaId: 2,
        headings: const ['Planning', 'Get packed', 'Things to buy'],
      );
      final back = Project.fromMap(project.toMap());
      expect(back.headings, ['Planning', 'Get packed', 'Things to buy']);
      expect(back.areaId, 2);
      expect(back.isCompleted, isFalse);
    });

    test('survives separators that a delimited format would split on', () {
      const awkward = ['Things, to buy', 'Get "packed"', "Don't forget"];
      final back =
          Project.fromMap(Project(title: 'p', headings: awkward).toMap());
      expect(back.headings, awkward);
    });

    test('a project stored before v8 reads as having no headings', () {
      // v7 rows have no headings column at all.
      final back = Project.fromMap({'id': 1, 'title': 'Old', 'isCompleted': 0});
      expect(back.headings, isEmpty);
    });

    test('an unparseable headings column degrades to empty', () {
      final back = Project.fromMap(
          {'id': 1, 'title': 'Old', 'isCompleted': 0, 'headings': '{oops'});
      expect(back.headings, isEmpty);
    });
  });
}
