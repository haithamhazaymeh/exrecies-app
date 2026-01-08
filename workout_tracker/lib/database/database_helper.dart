import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';
import '../models/workout_log.dart';
import '../models/body_weight_log.dart';
import '../models/workout_day.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workout_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // جدول التمارين
    await db.execute('''
      CREATE TABLE exercises (
        id $idType,
        name $textType,
        description $textType,
        type $textType,
        day TEXT,
        target_sets $integerType,
        target_reps $textType,
        image_path TEXT,
        category $textType,
        order_index $integerType
      )
    ''');

    // جدول سجلات التمارين
    await db.execute('''
      CREATE TABLE workout_logs (
        id $idType,
        exercise_id $integerType,
        date $textType,
        sets_completed $integerType,
        reps_completed $textType,
        weight_used $realType,
        notes TEXT,
        duration_minutes INTEGER,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    // جدول سجلات الوزن
    await db.execute('''
      CREATE TABLE body_weight_logs (
        id $idType,
        date $textType,
        weight $realType,
        notes TEXT
      )
    ''');

    // جدول أيام التمارين (للكاليندر)
    await db.execute('''
      CREATE TABLE workout_days (
        id $idType,
        date $textType UNIQUE,
        type $textType,
        completed INTEGER DEFAULT 1,
        notes TEXT
      )
    ''');

    // جدول الإعدادات
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // ==================== عمليات التمارين ====================
  
  Future<int> insertExercise(Exercise exercise) async {
    final db = await instance.database;
    return await db.insert('exercises', exercise.toMap());
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await instance.database;
    final result = await db.query('exercises', orderBy: 'order_index ASC');
    return result.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Exercise>> getExercisesByType(String type) async {
    final db = await instance.database;
    final result = await db.query(
      'exercises',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'order_index ASC',
    );
    return result.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Exercise>> getExercisesByDay(String day) async {
    final db = await instance.database;
    final result = await db.query(
      'exercises',
      where: 'day = ?',
      whereArgs: [day],
      orderBy: 'order_index ASC',
    );
    return result.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<Exercise?> getExercise(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await instance.database;
    return db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await instance.database;
    return await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== عمليات سجلات التمارين ====================

  Future<int> insertWorkoutLog(WorkoutLog log) async {
    final db = await instance.database;
    return await db.insert('workout_logs', log.toMap());
  }

  Future<List<WorkoutLog>> getAllWorkoutLogs() async {
    final db = await instance.database;
    final result = await db.query('workout_logs', orderBy: 'date DESC');
    return result.map((map) => WorkoutLog.fromMap(map)).toList();
  }

  Future<List<WorkoutLog>> getWorkoutLogsByExercise(int exerciseId) async {
    final db = await instance.database;
    final result = await db.query(
      'workout_logs',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'date DESC',
    );
    return result.map((map) => WorkoutLog.fromMap(map)).toList();
  }

  Future<WorkoutLog?> getLatestWorkoutLog(int exerciseId) async {
    final db = await instance.database;
    final result = await db.query(
      'workout_logs',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return WorkoutLog.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateWorkoutLog(WorkoutLog log) async {
    final db = await instance.database;
    return db.update(
      'workout_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteWorkoutLog(int id) async {
    final db = await instance.database;
    return await db.delete(
      'workout_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== عمليات سجلات الوزن ====================

  Future<int> insertBodyWeightLog(BodyWeightLog log) async {
    final db = await instance.database;
    return await db.insert('body_weight_logs', log.toMap());
  }

  Future<List<BodyWeightLog>> getAllBodyWeightLogs() async {
    final db = await instance.database;
    final result = await db.query('body_weight_logs', orderBy: 'date DESC');
    return result.map((map) => BodyWeightLog.fromMap(map)).toList();
  }

  Future<BodyWeightLog?> getLatestBodyWeight() async {
    final db = await instance.database;
    final result = await db.query(
      'body_weight_logs',
      orderBy: 'date DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return BodyWeightLog.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateBodyWeightLog(BodyWeightLog log) async {
    final db = await instance.database;
    return db.update(
      'body_weight_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteBodyWeightLog(int id) async {
    final db = await instance.database;
    return await db.delete(
      'body_weight_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== عمليات الإعدادات ====================

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  // ==================== إحصائيات ====================

  Future<int> getWorkoutCountThisMonth() async {
    final db = await instance.database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT date(date)) as count FROM workout_logs WHERE date >= ?',
      [firstDayOfMonth.toIso8601String()],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<Map<String, double>> getExercisePersonalRecord(int exerciseId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT MAX(weight_used) as max_weight, MAX(sets_completed) as max_sets FROM workout_logs WHERE exercise_id = ?',
      [exerciseId],
    );
    if (result.isNotEmpty) {
      return {
        'max_weight': (result.first['max_weight'] as double?) ?? 0.0,
        'max_sets': ((result.first['max_sets'] as int?) ?? 0).toDouble(),
      };
    }
    return {'max_weight': 0.0, 'max_sets': 0.0};
  }

  // ==================== عمليات أيام التمارين (للكاليندر) ====================

  Future<int> insertWorkoutDay(WorkoutDay day) async {
    final db = await instance.database;
    return await db.insert(
      'workout_days',
      day.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WorkoutDay>> getWorkoutDaysInMonth(DateTime month) async {
    final db = await instance.database;
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    
    final result = await db.query(
      'workout_days',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        WorkoutDay.dateToString(firstDay),
        WorkoutDay.dateToString(lastDay),
      ],
    );
    return result.map((map) => WorkoutDay.fromMap(map)).toList();
  }

  Future<WorkoutDay?> getWorkoutDay(DateTime date) async {
    final db = await instance.database;
    final result = await db.query(
      'workout_days',
      where: 'date = ?',
      whereArgs: [WorkoutDay.dateToString(date)],
    );
    if (result.isNotEmpty) {
      return WorkoutDay.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteWorkoutDay(DateTime date) async {
    final db = await instance.database;
    return await db.delete(
      'workout_days',
      where: 'date = ?',
      whereArgs: [WorkoutDay.dateToString(date)],
    );
  }

  // ==================== إغلاق القاعدة ====================

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
