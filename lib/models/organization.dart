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
  const Project({this.id, required this.title, this.areaId, this.isCompleted = false});
  Project copyWith({int? id, String? title, int? areaId, bool? isCompleted}) => Project(id: id ?? this.id, title: title ?? this.title, areaId: areaId ?? this.areaId, isCompleted: isCompleted ?? this.isCompleted);
  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'areaId': areaId, 'isCompleted': isCompleted ? 1 : 0};
  factory Project.fromMap(Map<String, dynamic> map) => Project(id: map['id'] as int?, title: map['title'] as String, areaId: map['areaId'] as int?, isCompleted: map['isCompleted'] == 1);
}
