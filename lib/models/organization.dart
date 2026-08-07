import 'dart:convert';

class Area {
  final int? id;
  final String title;
  final int accentColor;
  const Area({this.id, required this.title, this.accentColor = 0xFF7A9E91});
  Area copyWith({int? id, String? title, int? accentColor}) => Area(id: id ?? this.id, title: title ?? this.title, accentColor: accentColor ?? this.accentColor);
  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'accentColor': accentColor};
  factory Area.fromMap(Map<String, dynamic> map) => Area(id: map['id'] as int?, title: map['title'] as String, accentColor: (map['accentColor'] as int?) ?? 0xFF7A9E91);
}

class Project {
  final int? id;
  final String title;
  final int? areaId;
  final bool isCompleted;

  /// Section names, in the order they appear in the project. Held here rather
  /// than derived from the tasks so a heading you have just added survives
  /// until you put something under it.
  final List<String> headings;

  const Project({this.id, required this.title, this.areaId, this.isCompleted = false, this.headings = const []});
  Project copyWith({int? id, String? title, int? areaId, bool? isCompleted, List<String>? headings}) => Project(id: id ?? this.id, title: title ?? this.title, areaId: areaId ?? this.areaId, isCompleted: isCompleted ?? this.isCompleted, headings: headings ?? this.headings);
  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'areaId': areaId, 'isCompleted': isCompleted ? 1 : 0, 'headings': jsonEncode(headings)};
  factory Project.fromMap(Map<String, dynamic> map) => Project(id: map['id'] as int?, title: map['title'] as String, areaId: map['areaId'] as int?, isCompleted: map['isCompleted'] == 1, headings: _parseHeadings(map['headings'] as String?));

  /// JSON rather than a delimiter: a heading is free text and may contain
  /// whatever separator we would otherwise have picked.
  static List<String> _parseHeadings(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>).whereType<String>().toList();
    } catch (_) {
      return const [];
    }
  }
}
