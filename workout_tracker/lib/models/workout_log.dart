class WorkoutLog {
  final int? id;
  final int exerciseId;
  final DateTime date;
  final int setsCompleted;
  final String repsCompleted;
  final double weightUsed;
  final String? notes;
  final int? durationMinutes;

  WorkoutLog({
    this.id,
    required this.exerciseId,
    required this.date,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.weightUsed,
    this.notes,
    this.durationMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'date': date.toIso8601String(),
      'sets_completed': setsCompleted,
      'reps_completed': repsCompleted,
      'weight_used': weightUsed,
      'notes': notes,
      'duration_minutes': durationMinutes,
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    return WorkoutLog(
      id: map['id'] as int?,
      exerciseId: map['exercise_id'] as int,
      date: DateTime.parse(map['date'] as String),
      setsCompleted: map['sets_completed'] as int,
      repsCompleted: map['reps_completed'] as String,
      weightUsed: (map['weight_used'] as num).toDouble(),
      notes: map['notes'] as String?,
      durationMinutes: map['duration_minutes'] as int?,
    );
  }

  WorkoutLog copyWith({
    int? id,
    int? exerciseId,
    DateTime? date,
    int? setsCompleted,
    String? repsCompleted,
    double? weightUsed,
    String? notes,
    int? durationMinutes,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      date: date ?? this.date,
      setsCompleted: setsCompleted ?? this.setsCompleted,
      repsCompleted: repsCompleted ?? this.repsCompleted,
      weightUsed: weightUsed ?? this.weightUsed,
      notes: notes ?? this.notes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
