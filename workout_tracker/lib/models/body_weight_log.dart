class BodyWeightLog {
  final int? id;
  final DateTime date;
  final double weight;
  final String? notes;

  BodyWeightLog({
    this.id,
    required this.date,
    required this.weight,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'notes': notes,
    };
  }

  factory BodyWeightLog.fromMap(Map<String, dynamic> map) {
    return BodyWeightLog(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      weight: (map['weight'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }

  BodyWeightLog copyWith({
    int? id,
    DateTime? date,
    double? weight,
    String? notes,
  }) {
    return BodyWeightLog(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
    );
  }
}
