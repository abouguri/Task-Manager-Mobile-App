/// Task model class representing a task in the task management app
class Task {
  final int? id;
  final String title;
  final String? description;
  final String priority; // 'Low', 'Medium', 'High'
  final String category; // 'Work', 'Personal', 'Shopping', 'Health', 'Other'
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.category,
    this.dueDate,
    this.isCompleted = false,
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
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
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
      dueDate: map['dueDate'] != null 
          ? DateTime.parse(map['dueDate'] as String) 
          : null,
      isCompleted: map['isCompleted'] == 1,
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
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: $priority, category: $category, isCompleted: $isCompleted)';
  }
}
