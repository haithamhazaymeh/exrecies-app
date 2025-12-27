class Exercise {
  final int? id;
  final String name; // الاسم (للتوافقية مع الكود القديم)
  final String description; // الوصف (للتوافقية)
  
  // ثنائي اللغة
  final String? nameAr; // الاسم بالعربي
  final String? nameEn; // الاسم بالإنجليزي
  final String? descriptionAr; // الوصف بالعربي
  final String? descriptionEn; // الوصف بالإنجليزي
  
  final String type; // 'morning' أو 'gym'
  final String? day; // null للمنزلية، 'day1'-'day4' للنادي
  final int targetSets;
  final String targetReps;
  final String? imagePath;
  final String category; // 'kegel', 'posture', 'chest', 'back', etc.
  final int orderIndex;
  
  // معلومات إضافية
  final String? targetMuscle; // العضلة المستهدفة
  final String? targetAngle; // الزاوية المستهدفة
  final String? difficulty; // 'سهل', 'متوسط', 'صعب'
  final String? equipment; // المعدات المطلوبة

  Exercise({
    this.id,
    required this.name,
    required this.description,
    this.nameAr,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.type,
    this.day,
    required this.targetSets,
    required this.targetReps,
    this.imagePath,
    required this.category,
    this.orderIndex = 0,
    this.targetMuscle,
    this.targetAngle,
    this.difficulty,
    this.equipment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'type': type,
      'day': day,
      'target_sets': targetSets,
      'target_reps': targetReps,
      'image_path': imagePath,
      'category': category,
      'order_index': orderIndex,
      'target_muscle': targetMuscle,
      'target_angle': targetAngle,
      'difficulty': difficulty,
      'equipment': equipment,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      nameAr: map['name_ar'] as String?,
      nameEn: map['name_en'] as String?,
      descriptionAr: map['description_ar'] as String?,
      descriptionEn: map['description_en'] as String?,
      type: map['type'] as String,
      day: map['day'] as String?,
      targetSets: map['target_sets'] as int,
      targetReps: map['target_reps'] as String,
      imagePath: map['image_path'] as String?,
      category: map['category'] as String,
      orderIndex: map['order_index'] as int? ?? 0,
      targetMuscle: map['target_muscle'] as String?,
      targetAngle: map['target_angle'] as String?,
      difficulty: map['difficulty'] as String?,
      equipment: map['equipment'] as String?,
    );
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? description,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? type,
    String? day,
    int? targetSets,
    String? targetReps,
    String? imagePath,
    String? category,
    int? orderIndex,
    String? targetMuscle,
    String? targetAngle,
    String? difficulty,
    String? equipment,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      type: type ?? this.type,
      day: day ?? this.day,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      orderIndex: orderIndex ?? this.orderIndex,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      targetAngle: targetAngle ?? this.targetAngle,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
    );
  }
  
  // Helper getters
  String get displayNameAr => nameAr ?? name;
  String get displayNameEn => nameEn ?? name;
  String get displayDescriptionAr => descriptionAr ?? description;
  String get displayDescriptionEn => descriptionEn ?? description;
}
