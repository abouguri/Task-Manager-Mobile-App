/// Task model class representing a task in the task management app
class Task {
  final int? id;
  final String title;
  final String? description;
  final String priority; // 'Low', 'Medium', 'High'
  final String category; // 'Work', 'Personal', 'Shopping', 'Health', 'Other'
  final List<String> tags;
  final int effortMinutes;
  final String energyLevel; // 'Deep Work', 'Quick Win', 'Flexible'
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.category,
    this.tags = const [],
    this.effortMinutes = 15,
    this.energyLevel = 'Flexible',
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Task object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      'tags': tags.join(','),
      'effortMinutes': effortMinutes,
      'energyLevel': energyLevel,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create Task object from Map (database query result)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      priority: map['priority'] as String,
      category: map['category'] as String,
        tags: _parseTags(map['tags'] as String?),
        effortMinutes: (map['effortMinutes'] as int?) ?? 15,
        energyLevel: (map['energyLevel'] as String?) ?? 'Flexible',
      dueDate: map['dueDate'] != null 
          ? DateTime.parse(map['dueDate'] as String) 
          : null,
      isCompleted: map['isCompleted'] == 1,
        completedAt: map['completedAt'] != null
            ? DateTime.parse(map['completedAt'] as String)
            : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Create a copy of Task with modified fields
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? priority,
    String? category,
    List<String>? tags,
    int? effortMinutes,
    String? energyLevel,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      effortMinutes: effortMinutes ?? this.effortMinutes,
      energyLevel: energyLevel ?? this.energyLevel,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<String> _parseTags(String? rawTags) {
    if (rawTags == null || rawTags.trim().isEmpty) {
      return const [];
    }

    return rawTags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: $priority, category: $category, isCompleted: $isCompleted)';
  }
}
