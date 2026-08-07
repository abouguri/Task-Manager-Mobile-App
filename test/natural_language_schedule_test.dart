import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/natural_language_schedule.dart';

void main() {
  // A Friday, so weekday arithmetic is checkable by hand.
  final now = DateTime(2026, 8, 7);

  ParsedSchedule parse(String input) =>
      NaturalLanguageSchedule.parse(input, now: now);

  group('recognised phrases', () {
    test('tomorrow', () {
      final result = parse('Call the dentist tomorrow');
      expect(result.title, 'Call the dentist');
      expect(result.when, TaskWhen.date);
      expect(result.date, DateTime(2026, 8, 8));
    });

    test('someday', () {
      final result = parse('Learn to sail someday');
      expect(result.title, 'Learn to sail');
      expect(result.when, TaskWhen.someday);
      expect(result.date, isNull);
    });

    test('in N days', () {
      final result = parse('Send invitations in 3 days');
      expect(result.title, 'Send invitations');
      expect(result.date, DateTime(2026, 8, 10));
    });

    test('a weekday resolves forwards, today included', () {
      // "friday" on a Friday means today, not next week.
      expect(parse('Ship it friday').date, DateTime(2026, 8, 7));
      expect(parse('Ship it monday').date, DateTime(2026, 8, 10));
    });

    test('next <weekday> always skips ahead', () {
      expect(parse('Review next friday').date, DateTime(2026, 8, 14),
          reason: '"next friday" on a Friday should not mean today');
    });

    test('a weekday can carry a time', () {
      final result = parse('Standup monday at 9:30 am');
      expect(result.title, 'Standup');
      expect(result.date, DateTime(2026, 8, 10, 9, 30));
    });

    test('pm is carried into the 24-hour clock', () {
      expect(parse('Dinner monday at 7 pm').date, DateTime(2026, 8, 10, 19));
    });

    test('every <weekday> sets a recurrence', () {
      final result = parse('Water the plants every friday');
      expect(result.title, 'Water the plants');
      expect(result.recurrence, 'weekly:${DateTime.friday}');
      expect(result.date, DateTime(2026, 8, 7));
    });
  });

  group('left alone', () {
    // KNOWN SHARP EDGE, pinned rather than asserted as desirable.
    //
    // The parser documents itself as "intentionally narrow: unfamiliar text
    // stays a task title rather than becoming a surprising date", but any
    // weekday word anywhere in a title is matched, removed from the title, and
    // turned into a schedule. "Plan the monday standup agenda" is stored as
    // "Plan the standup agenda" on Monday. This test exists so the behaviour
    // cannot change unnoticed, not because it is right.
    test('a bare weekday anywhere in a title is consumed as a date', () {
      final result = parse('Plan the monday standup agenda');
      expect(result.title, 'Plan the standup agenda');
      expect(result.when, TaskWhen.date);
      expect(result.date, DateTime(2026, 8, 10));
    });

    test('unfamiliar phrasing stays a title', () {
      final result = parse('Ping Ana re: Q3 numbers');
      expect(result.title, 'Ping Ana re: Q3 numbers');
      expect(result.when, TaskWhen.inbox);
      expect(result.date, isNull);
      expect(result.recurrence, isNull);
    });

    test('empty input stays empty', () {
      expect(parse('   ').title, isEmpty);
    });
  });

  group('nextOccurrence', () {
    test('weekly always lands on the following matching weekday', () {
      final next = NaturalLanguageSchedule.nextOccurrence(
          'weekly:${DateTime.friday}', DateTime(2026, 8, 7));
      expect(next, DateTime(2026, 8, 14),
          reason: 'completing a Friday task must not reschedule it to itself');
    });

    test('an unknown recurrence falls back to the next day', () {
      expect(NaturalLanguageSchedule.nextOccurrence('daily', DateTime(2026, 8, 7)),
          DateTime(2026, 8, 8));
    });
  });
}
