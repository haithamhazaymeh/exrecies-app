class Exercise {
  final int? id;
  final String name;
  final String description;
  final String type; // 'morning' أو 'gym'
  final String? day; // null للمنزلية، 'day1'-'day4' للنادي
  final int targetSets;
  final String targetReps;
  final String? imagePath;
  final String category; // 'kegel', 'posture', 'chest', 'back', etc.
  final int orderIndex;

  Exercise({
    this.id,
    required this.name,
    required this.description,
    required this.type,
    this.day,
    required this.targetSets,
    required this.targetReps,
    this.imagePath,
    required this.category,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'day': day,
      'target_sets': targetSets,
      'target_reps': targetReps,
      'image_path': imagePath,
      'category': category,
      'order_index': orderIndex,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      day: map['day'] as String?,
      targetSets: map['target_sets'] as int,
      targetReps: map['target_reps'] as String,
      imagePath: map['image_path'] as String?,
      category: map['category'] as String,
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? description,
    String? type,
    String? day,
    int? targetSets,
    String? targetReps,
    String? imagePath,
    String? category,
    int? orderIndex,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      day: day ?? this.day,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
