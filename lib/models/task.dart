import 'dart:convert';

enum TaskWhen { inbox, today, evening, date, anytime, someday }

class ChecklistItem {
  final String title;
  final bool isCompleted;
  const ChecklistItem({required this.title, this.isCompleted = false});
  ChecklistItem copyWith({String? title, bool? isCompleted}) => ChecklistItem(
      title: title ?? this.title, isCompleted: isCompleted ?? this.isCompleted);
  Map<String, dynamic> toMap() => {'title': title, 'isCompleted': isCompleted};
  factory ChecklistItem.fromMap(Map<String, dynamic> map) => ChecklistItem(
      title: map['title'] as String? ?? '',
      isCompleted: map['isCompleted'] == true || map['isCompleted'] == 1);
}

/// A deliberately small task record. The old category/priority fields are
/// retained only as migration compatibility accessors; new UI never exposes them.
class Task {
  final int? id;
  final String title;
  final String? description;
  final List<String> tags;
  final List<ChecklistItem> checklist;
  final TaskWhen when;
  final DateTime? scheduledFor;
  final DateTime? deadline;
  final String? projectId;
  final String? areaId;

  /// Which of the project's headings this sits under. Null means it belongs to
  /// the project but to no section, and renders above the first heading.
  final String? heading;

  final String? recurrence;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description,
    this.tags = const [],
    this.checklist = const [],
    this.when = TaskWhen.inbox,
    this.scheduledFor,
    this.deadline,
    this.projectId,
    this.areaId,
    this.heading,
    this.recurrence,
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Compatibility values for pre-redesign screens and stored databases.
  String get priority => 'None';
  String get category => projectId ?? areaId ?? 'Inbox';
  int get effortMinutes => 0;
  String get energyLevel => 'Flexible';
  DateTime? get dueDate => scheduledFor;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        // Kept in storage so v3 databases with NOT NULL legacy columns can
        // receive redesigned tasks. They are never shown or used by the UI.
        'priority': 'None',
        'category': projectId ?? areaId ?? 'Inbox',
        'tags': tags.join(','),
        'checklist': jsonEncode(checklist.map((item) => item.toMap()).toList()),
        'effortMinutes': 0,
        'energyLevel': 'Flexible',
        'dueDate': scheduledFor?.toIso8601String(),
        'whenValue': when.name,
        'scheduledFor': scheduledFor?.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'projectId': projectId,
        'areaId': areaId,
        'heading': heading,
        'recurrence': recurrence,
        'isCompleted': isCompleted ? 1 : 0,
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromMap(Map<String, dynamic> map) {
    final oldDueDate = map['dueDate'] as String?;
    final scheduled = map['scheduledFor'] as String? ?? oldDueDate;
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      tags: _parseTags(map['tags'] as String?),
      checklist: _parseChecklist(map['checklist'] as String?),
      when: _whenFrom(map['whenValue'] as String?, scheduled),
      scheduledFor: scheduled == null ? null : DateTime.tryParse(scheduled),
      deadline: map['deadline'] == null
          ? null
          : DateTime.tryParse(map['deadline'] as String),
      projectId: map['projectId'] as String? ??
          _legacyProject(map['category'] as String?),
      areaId: map['areaId'] as String?,
      heading: map['heading'] as String?,
      recurrence: map['recurrence'] as String?,
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.tryParse(map['completedAt'] as String),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    List<String>? tags,
    List<ChecklistItem>? checklist,
    TaskWhen? when,
    DateTime? scheduledFor,
    bool clearScheduledFor = false,
    DateTime? deadline,
    bool clearDeadline = false,
    String? projectId,
    String? areaId,
    String? heading,
    bool clearHeading = false,
    String? recurrence,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? createdAt,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        checklist: checklist ?? this.checklist,
        when: when ?? this.when,
        scheduledFor:
            clearScheduledFor ? null : scheduledFor ?? this.scheduledFor,
        deadline: clearDeadline ? null : deadline ?? this.deadline,
        projectId: projectId ?? this.projectId,
        areaId: areaId ?? this.areaId,
        heading: clearHeading ? null : heading ?? this.heading,
        recurrence: recurrence ?? this.recurrence,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
      );

  static TaskWhen _whenFrom(String? raw, String? scheduled) =>
      TaskWhen.values.where((value) => value.name == raw).firstOrNull ??
      (scheduled == null ? TaskWhen.inbox : TaskWhen.date);
  static String? _legacyProject(String? category) =>
      category == null || category == 'Personal' || category == 'Inbox'
          ? null
          : category;
  static List<String> _parseTags(String? raw) =>
      raw == null || raw.trim().isEmpty
          ? const []
          : raw
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
  static List<ChecklistItem> _parseChecklist(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final values = jsonDecode(raw) as List<dynamic>;
      return values
          .whereType<Map>()
          .map((value) =>
              ChecklistItem.fromMap(Map<String, dynamic>.from(value)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
