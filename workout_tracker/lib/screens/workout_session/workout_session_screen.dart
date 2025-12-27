import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../models/workout_session.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import 'dart:async';

class WorkoutSessionScreen extends StatefulWidget {
  final List<Exercise> exercises;
  final String sessionType; // 'morning' or 'gym'
  final String? dayName; // للجيم فقط

  const WorkoutSessionScreen({
    super.key,
    required this.exercises,
    required this.sessionType,
    this.dayName,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int currentExerciseIndex = 0;
  int currentSet = 1;
  List<ExerciseSet> completedSets = [];
  late DateTime sessionStartTime;
  Timer? _timer;
  int _elapsedSeconds = 0;
  
  // Rest timer
  bool isResting = false;
  int restSeconds = 60;
  Timer? _restTimer;

  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    sessionStartTime = DateTime.now();
    _startSessionTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _startSessionTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _startRestTimer() {
    setState(() {
      isResting = true;
      restSeconds = 60; // راحة دقيقة
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        restSeconds--;
        if (restSeconds <= 0) {
          _restTimer?.cancel();
          isResting = false;
          HapticFeedback.heavyImpact();
        }
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      isResting = false;
    });
  }

  void _completeSet() {
    final reps = int.tryParse(_repsController.text);
    if (reps == null || reps == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل عدد العدات!')),
      );
      return;
    }

    final weight = double.tryParse(_weightController.text);
    final exercise = widget.exercises[currentExerciseIndex];

    final set = ExerciseSet(
      sessionId: 0, // سيتم تحديثه عند الحفظ
      exerciseId: exercise.id!,
      setNumber: currentSet,
      reps: reps,
      weight: weight,
      completedAt: DateTime.now(),
    );

    setState(() {
      completedSets.add(set);
      
      // إذا كانت هذه آخر مجموعة للتمرين الحالي
      if (currentSet >= exercise.targetSets) {
        // انتقل للتمرين التالي
        if (currentExerciseIndex < widget.exercises.length - 1) {
          currentExerciseIndex++;
          currentSet = 1;
        } else {
          // انتهت الجلسة!
          _finishSession();
          return;
        }
      } else {
        // مجموعة أخرى من نفس التمرين
        currentSet++;
        _startRestTimer();
      }

      // مسح الحقول
      _repsController.clear();
      _weightController.clear();
    });

    HapticFeedback.mediumImpact();
  }

  void _finishSession() {
    // حفظ الجلسة
    final session = WorkoutSession(
      type: widget.sessionType,
      day: widget.dayName,
      startTime: sessionStartTime,
      endTime: DateTime.now(),
      sets: completedSets,
    );

    // حفظ يوم التمرين في الكاليندر
    context.read<WorkoutProvider>().saveWorkoutDay(widget.sessionType);

    // عرض شاشة التهنئة
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 رائع!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'لقد أكملت جلسة التمرين!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('المدة: ${_formatDuration(session.duration)}'),
            Text('التمارين: ${session.completedExercises}'),
            Text('المجموعات: ${session.totalSets}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق dialog
              Navigator.pop(context); // العودة للشاشة السابقة
            },
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.exercises[currentExerciseIndex];
    final progress = (currentExerciseIndex + 1) / widget.exercises.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sessionType == 'morning' ? 'روتين الصباح' : widget.dayName}'),
        actions: [
          // مؤقت الجلسة
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              avatar: const Icon(Icons.timer, size: 16),
              label: Text(_formatDuration(Duration(seconds: _elapsedSeconds))),
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
      body: isResting ? _buildRestScreen() : _buildExerciseScreen(currentExercise, progress),
    );
  }

  Widget _buildRestScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.orangeGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.self_improvement,
              size: 100,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            const Text(
              'وقت الراحة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$restSeconds',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ثانية',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _skipRest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.secondaryOrange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('تخطي'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseScreen(Exercise exercise, double progress) {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Exercise info
                Text(
                  'تمرين ${currentExerciseIndex + 1} من ${widget.exercises.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  exercise.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                // Set info
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'المجموعة $currentSet من ${exercise.targetSets}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الهدف: ${exercise.targetReps} عدة',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Input fields
                TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'عدد العدات',
                    hintText: exercise.targetReps,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'الوزن (كجم) - اختياري',
                    hintText: '0',
                    border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Complete set button
                ElevatedButton(
                  onPressed: _completeSet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إنهاء المجموعة ✓',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
