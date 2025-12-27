import 'package:flutter/foundation.dart';
import 'exercise.dart';

/// نموذج لتتبع جلسة تمرين نشطة
class WorkoutSession {
  final int? id;
  final String type; // 'morning' أو 'gym'
  final String? day; // لتمارين النادي: 'day1', 'day2', etc
  final DateTime startTime;
  final DateTime? endTime;
  final List<ExerciseSet> sets;
  
  WorkoutSession({
    this.id,
    required this.type,
    this.day,
    required this.startTime,
    this.endTime,
    this.sets = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'day': day,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as int?,
      type: map['type'] as String,
      day: map['day'] as String?,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null 
          ? DateTime.parse(map['end_time'] as String) 
          : null,
    );
  }

  WorkoutSession copyWith({
    int? id,
    String? type,
    String? day,
    DateTime? startTime,
    DateTime? endTime,
    List<ExerciseSet>? sets,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      type: type ?? this.type,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sets: sets ?? this.sets,
    );
  }

  /// حساب مدة الجلسة
  Duration get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  /// عدد التمارين المكتملة
  int get completedExercises {
    return sets.map((s) => s.exerciseId).toSet().length;
  }

  /// إجمالي المجموعات
  int get totalSets => sets.length;
}

/// نموذج لمجموعة واحدة من تمرين
class ExerciseSet {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final int setNumber; // رقم المجموعة (1, 2, 3, ...)
  final int reps; // عدد العدات
  final double? weight; // الوزن المستخدم (اختياري)
  final String? notes; // ملاحظات
  final DateTime completedAt;

  ExerciseSet({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    this.weight,
    this.notes,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
      'notes': notes,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      exerciseId: map['exercise_id'] as int,
      setNumber: map['set_number'] as int,
      reps: map['reps'] as int,
      weight: map['weight'] as double?,
      notes: map['notes'] as String?,
      completedAt: DateTime.parse(map['completed_at'] as String),
    );
  }

  ExerciseSet copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    int? setNumber,
    int? reps,
    double? weight,
    String? notes,
    DateTime? completedAt,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
