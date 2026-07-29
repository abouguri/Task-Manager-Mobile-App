import '../models/task.dart';

class ParsedSchedule {
  final String title;
  final TaskWhen when;
  final DateTime? date;
  final String? recurrence;
  const ParsedSchedule(
      {required this.title, required this.when, this.date, this.recurrence});
}

/// Intentionally narrow: common phrases should feel invisible, unfamiliar text
/// stays a task title rather than becoming a surprising date.
class NaturalLanguageSchedule {
  static ParsedSchedule parse(String input, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    var title = input.trim();
    var when = TaskWhen.inbox;
    DateTime? date;
    String? recurrence;
    final lower = title.toLowerCase();

    if (RegExp(r'\bsomeday\b').hasMatch(lower)) {
      title = title.replaceFirst(
          RegExp(r'\s*\bsomeday\b', caseSensitive: false), '');
      when = TaskWhen.someday;
    } else if (RegExp(r'\btomorrow\b').hasMatch(lower)) {
      title = title.replaceFirst(
          RegExp(r'\s*\btomorrow\b', caseSensitive: false), '');
      when = TaskWhen.date;
      date = _startOfDay(reference).add(const Duration(days: 1));
    } else {
      final inDays = RegExp(r'\bin\s+(\d+)\s+days?\b', caseSensitive: false)
          .firstMatch(title);
      final every = RegExp(
              r'\bevery\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
              caseSensitive: false)
          .firstMatch(title);
      final next = RegExp(
              r'\bnext\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
              caseSensitive: false)
          .firstMatch(title);
      final weekday = RegExp(
              r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)(?:\s+at\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?)?\b',
              caseSensitive: false)
          .firstMatch(title);
      if (inDays != null) {
        title = title.replaceFirst(inDays.group(0)!, '').trim();
        when = TaskWhen.date;
        date = _startOfDay(reference)
            .add(Duration(days: int.parse(inDays.group(1)!)));
      } else if (every != null) {
        final day = _weekday(every.group(1)!);
        title = title.replaceFirst(every.group(0)!, '').trim();
        when = TaskWhen.date;
        date = _nextWeekday(reference, day, includeToday: true);
        recurrence = 'weekly:$day';
      } else if (next != null || weekday != null) {
        final match = next ?? weekday!;
        title = title.replaceFirst(match.group(0)!, '').trim();
        when = TaskWhen.date;
        date = _nextWeekday(reference, _weekday(match.group(1)!),
            includeToday: next == null);
        if (weekday?.group(2) != null)
          date = _withTime(
              date, weekday!.group(2)!, weekday.group(3), weekday.group(4));
      }
    }
    return ParsedSchedule(
        title: title.replaceAll(RegExp(r'\s+'), ' ').trim(),
        when: when,
        date: date,
        recurrence: recurrence);
  }

  static DateTime nextOccurrence(String recurrence, DateTime from) {
    if (recurrence.startsWith('weekly:')) {
      final weekday = int.tryParse(recurrence.substring(7)) ?? from.weekday;
      return _nextWeekday(from.add(const Duration(days: 1)), weekday,
          includeToday: true);
    }
    return from.add(const Duration(days: 1));
  }

  static DateTime _startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);
  static DateTime _withTime(
      DateTime date, String hourRaw, String? minuteRaw, String? period) {
    var hour = int.parse(hourRaw);
    if (period?.toLowerCase() == 'pm' && hour < 12) hour += 12;
    if (period?.toLowerCase() == 'am' && hour == 12) hour = 0;
    return DateTime(date.year, date.month, date.day, hour,
        int.tryParse(minuteRaw ?? '') ?? 0);
  }

  static DateTime _nextWeekday(DateTime from, int weekday,
      {required bool includeToday}) {
    final start = _startOfDay(from);
    var days = (weekday - start.weekday + 7) % 7;
    if (!includeToday && days == 0) days = 7;
    return start.add(Duration(days: days));
  }

  static int _weekday(String value) => const {
        'monday': DateTime.monday,
        'tuesday': DateTime.tuesday,
        'wednesday': DateTime.wednesday,
        'thursday': DateTime.thursday,
        'friday': DateTime.friday,
        'saturday': DateTime.saturday,
        'sunday': DateTime.sunday
      }[value.toLowerCase()]!;
}
