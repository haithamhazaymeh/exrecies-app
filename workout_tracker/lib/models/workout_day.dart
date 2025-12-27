import 'package:flutter/foundation.dart';

/// نموذج ليوم تمرين في الكاليندر
class WorkoutDay {
  final int? id;
  final DateTime date;
  final String type; // 'morning', 'gym', 'both'
  final bool completed;
  final String? notes;

  WorkoutDay({
    this.id,
    required this.date,
    required this.type,
    this.completed = true,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': _dateToString(date),
      'type': type,
      'completed': completed ? 1 : 0,
      'notes': notes,
    };
  }

  factory WorkoutDay.fromMap(Map<String, dynamic> map) {
    return WorkoutDay(
      id: map['id'] as int?,
      date: _stringToDate(map['date'] as String),
      type: map['type'] as String,
      completed: (map['completed'] as int) == 1,
      notes: map['notes'] as String?,
    );
  }

  WorkoutDay copyWith({
    int? id,
    DateTime? date,
    String? type,
    bool? completed,
    String? notes,
  }) {
    return WorkoutDay(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }

  /// تحويل DateTime إلى String بصيغة yyyy-MM-dd
  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// تحويل String إلى DateTime
  static DateTime _stringToDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// مقارنة التواريخ بدون الوقت
  bool isSameDay(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutDay &&
          runtimeType == other.runtimeType &&
          isSameDay(other.date) &&
          type == other.type;

  @override
  int get hashCode => date.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'WorkoutDay{id: $id, date: ${_dateToString(date)}, type: $type, completed: $completed}';
  }
}
