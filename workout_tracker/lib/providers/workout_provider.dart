import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../models/workout_log.dart';
import '../models/body_weight_log.dart';
import '../models/workout_day.dart';
import '../database/database_helper.dart';
import '../data/initial_exercises.dart';

class WorkoutProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Exercise> _exercises = [];
  List<WorkoutLog> _workoutLogs = [];
  List<BodyWeightLog> _bodyWeightLogs = [];
  bool _isLoading = false;
  bool _isDatabaseAvailable = true;

  List<Exercise> get exercises => _exercises;
  List<WorkoutLog> get workoutLogs => _workoutLogs;
  List<BodyWeightLog> get bodyWeightLogs => _bodyWeightLogs;
  bool get isLoading => _isLoading;

  // الحصول على التمارين المنزلية
  List<Exercise> get morningExercises =>
      _exercises.where((e) => e.type == 'morning').toList();

  // الحصول على تمارين النادي
  List<Exercise> get gymExercises =>
      _exercises.where((e) => e.type == 'gym').toList();

  // الحصول على تمارين يوم معين
  List<Exercise> getExercisesByDay(String day) =>
      _exercises.where((e) => e.day == day).toList();

  // الحصول على أحدث وزن للجسم
  BodyWeightLog? get latestBodyWeight =>
      _bodyWeightLogs.isNotEmpty ? _bodyWeightLogs.first : null;

  // تحميل جميع البيانات
  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await _dbHelper.getAllExercises();
      _workoutLogs = await _dbHelper.getAllWorkoutLogs();
      _bodyWeightLogs = await _dbHelper.getAllBodyWeightLogs();
      _isDatabaseAvailable = true;
    } catch (e) {
      debugPrint('قاعدة البيانات غير متاحة، استخدام البيانات من الذاكرة: $e');
      _isDatabaseAvailable = false;
      // تحميل التمارين من الذاكرة
      _loadFromMemory();
    }

    _isLoading = false;
    notifyListeners();
  }

  // تحميل البيانات من الذاكرة (للويب)
  void _loadFromMemory() {
    _exercises = InitialExercises.getAllExercises()
        .asMap()
        .entries
        .map((entry) => entry.value.copyWith(id: entry.key + 1))
        .toList();
    
    // إضافة بعض البيانات التجريبية
    _bodyWeightLogs = [
      BodyWeightLog(
        id: 1,
        date: DateTime.now().subtract(const Duration(days: 7)),
        weight: 93.0,
        notes: 'الوزن الابتدائي',
      ),
      BodyWeightLog(
        id: 2,
        date: DateTime.now(),
        weight: 91.5,
        notes: 'تقدم جيد!',
      ),
    ];
  }

  // ==================== عمليات التمارين ====================

  Future<void> addExercise(Exercise exercise) async {
    try {
      final id = await _dbHelper.insertExercise(exercise);
      _exercises.add(exercise.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في إضافة التمرين: $e');
    }
  }

  Future<void> updateExercise(Exercise exercise) async {
    try {
      await _dbHelper.updateExercise(exercise);
      final index = _exercises.indexWhere((e) => e.id == exercise.id);
      if (index != -1) {
        _exercises[index] = exercise;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطأ في تحديث التمرين: $e');
    }
  }

  Future<void> deleteExercise(int id) async {
    try {
      await _dbHelper.deleteExercise(id);
      _exercises.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في حذف التمرين: $e');
    }
  }

  // ==================== عمليات سجلات التمارين ====================

  Future<void> addWorkoutLog(WorkoutLog log) async {
    try {
      final id = await _dbHelper.insertWorkoutLog(log);
      _workoutLogs.insert(0, log.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في إضافة سجل التمرين: $e');
    }
  }

  Future<void> updateWorkoutLog(WorkoutLog log) async {
    try {
      await _dbHelper.updateWorkoutLog(log);
      final index = _workoutLogs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _workoutLogs[index] = log;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطأ في تحديث سجل التمرين: $e');
    }
  }

  Future<void> deleteWorkoutLog(int id) async {
    try {
      await _dbHelper.deleteWorkoutLog(id);
      _workoutLogs.removeWhere((l) => l.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في حذف سجل التمرين: $e');
    }
  }

  List<WorkoutLog> getWorkoutLogsForExercise(int exerciseId) {
    return _workoutLogs
        .where((log) => log.exerciseId == exerciseId)
        .toList();
  }

  // ==================== عمليات سجلات الوزن ====================

  Future<void> addBodyWeightLog(BodyWeightLog log) async {
    try {
      final id = await _dbHelper.insertBodyWeightLog(log);
      _bodyWeightLogs.insert(0, log.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في إضافة سجل الوزن: $e');
    }
  }

  Future<void> updateBodyWeightLog(BodyWeightLog log) async {
    try {
      await _dbHelper.updateBodyWeightLog(log);
      final index = _bodyWeightLogs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _bodyWeightLogs[index] = log;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطأ في تحديث سجل الوزن: $e');
    }
  }

  Future<void> deleteBodyWeightLog(int id) async {
    try {
      await _dbHelper.deleteBodyWeightLog(id);
      _bodyWeightLogs.removeWhere((l) => l.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في حذف سجل الوزن: $e');
    }
  }

  // ==================== الإحصائيات ====================

  Future<int> getWorkoutCountThisMonth() async {
    try {
      return await _dbHelper.getWorkoutCountThisMonth();
    } catch (e) {
      debugPrint('خطأ في حساب التمارين: $e');
      return 0;
    }
  }

  Future<Map<String, double>> getExercisePR(int exerciseId) async {
    try {
      return await _dbHelper.getExercisePersonalRecord(exerciseId);
    } catch (e) {
      debugPrint('خطأ في الحصول على الرقم القياسي: $e');
      return {'max_weight': 0.0, 'max_sets': 0.0};
    }
  }

  // حساب نسبة التقدم نحو الهدف (93 -> 80 كجم)
  double getProgressPercentage() {
    if (latestBodyWeight == null) return 0.0;
    
    const double startWeight = 93.0;
    const double targetWeight = 80.0;
    final double currentWeight = latestBodyWeight!.weight;
    
    if (currentWeight >= startWeight) return 0.0;
    if (currentWeight <= targetWeight) return 100.0;
    
    final double totalLoss = startWeight - targetWeight; // 13 كجم
    final double currentLoss = startWeight - currentWeight;
    
    return (currentLoss / totalLoss) * 100;
  }

  // الوزن المتبقي للوصول للهدف
  double getRemainingWeight() {
    if (latestBodyWeight == null) return 13.0;
    
    const double targetWeight = 80.0;
    final double currentWeight = latestBodyWeight!.weight;
    
    return currentWeight - targetWeight;
  }

  // ==================== عمليات الكاليندر ====================

  Future<void> saveWorkoutDay(String type) async {
    try {
      final now = DateTime.now();
      // نحفظ التاريخ فقط بدون الوقت لتوحيد المقارنة
      final today = DateTime(now.year, now.month, now.day);
      
      final workoutDay = WorkoutDay(
        date: today,
        type: type,
        completed: true,
      );

      await _dbHelper.insertWorkoutDay(workoutDay);
      notifyListeners();
      debugPrint('تم حفظ يوم التمرين: $type في $today');
    } catch (e) {
      debugPrint('خطأ في حفظ يوم التمرين: $e');
    }
  }
}
