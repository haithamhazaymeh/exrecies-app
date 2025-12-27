import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise.dart';
import '../../services/image_service.dart';

class GymScheduleScreen extends StatefulWidget {
  const GymScheduleScreen({super.key});

  @override
  State<GymScheduleScreen> createState() => _GymScheduleScreenState();
}

class _GymScheduleScreenState extends State<GymScheduleScreen> {
  String selectedDay = 'day1';

  final Map<String, Map<String, String>> dayInfo = {
    'day1': {
      'title': 'اليوم الأول',
      'subtitle': 'علوي (صدر + ظهر + سواعد)',
      'emoji': '💪',
    },
    'day2': {
      'title': 'اليوم الثاني',
      'subtitle': 'أرجل (تنسيق وشد)',
      'emoji': '🦵',
    },
    'day3': {
      'title': 'اليوم الثالث',
      'subtitle': 'تفجير الذراعين (باي + تراي)',
      'emoji': '💥',
    },
    'day4': {
      'title': 'اليوم الرابع',
      'subtitle': 'أكتاف + كور',
      'emoji': '🏋️',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'جدول النادي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '4-5 أيام أسبوعياً 🔥',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Day selector
                  _buildDaySelector(),
                ],
              ),
            ),
          ),

          // Exercise list
          Expanded(
            child: Consumer<WorkoutProvider>(
              builder: (context, provider, child) {
                final exercises = provider.getExercisesByDay(selectedDay);

                if (exercises.isEmpty) {
                  return const Center(
                    child: Text('لا توجد تمارين لهذا اليوم'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exercises.length + 1,
                  itemBuilder: (context, index) {
                    if (index == exercises.length) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentRed.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.directions_run, color: AppTheme.accentRed),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '• كارديو: 30 دقيقة مشي منحدر',
                                style: TextStyle(
                                  color: AppTheme.accentRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return _buildExerciseCard(context, exercises[index], provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _startWorkoutSession(context, selectedDay);
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('ابدأ التمرين'),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 4,
        itemBuilder: (context, index) {
          final dayKey = 'day${index + 1}';
          final info = dayInfo[dayKey]!;
          final isSelected = selectedDay == dayKey;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = dayKey;
              });
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    info['emoji']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info['title']!,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryBlue : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info['subtitle']!,
                    style: TextStyle(
                      color: isSelected ? AppTheme.textSecondary : Colors.white70,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise, WorkoutProvider provider) {
    final categoryColor = AppTheme.getCategoryColor(exercise.category);

    return FutureBuilder<Map<String, double>>(
      future: provider.getExercisePR(exercise.id!),
      builder: (context, snapshot) {
        final pr = snapshot.data;
        final maxWeight = pr?['max_weight'] ?? 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: categoryColor.withOpacity(0.3), width: 2),
          ),
          child: InkWell(
            onTap: () {
              _showExerciseDetail(context, exercise, maxWeight);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon or Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: exercise.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              exercise.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  AppTheme.getCategoryIcon(exercise.category),
                                  color: categoryColor,
                                  size: 32,
                                );
                              },
                            ),
                          )
                        : Icon(
                            AppTheme.getCategoryIcon(exercise.category),
                            color: categoryColor,
                            size: 32,
                          ),
                  ),
                  const SizedBox(width: 16),

                  // Exercise info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${exercise.targetSets} × ${exercise.targetReps}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            if (maxWeight > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'PR: ${maxWeight.toStringAsFixed(1)} كجم',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.successGreen,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.chevron_left,
                    color: categoryColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExerciseDetail(BuildContext context, Exercise exercise, double currentPR) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                exercise.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Exercise image upload option
              if (exercise.imagePath == null)
                ElevatedButton.icon(
                  onPressed: () async {
                    final imagePath = await ImageService.instance.pickImageFromGallery();
                    if (imagePath != null) {
                      final updatedExercise = exercise.copyWith(imagePath: imagePath);
                      context.read<WorkoutProvider>().updateExercise(updatedExercise);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة الصورة بنجاح! ✅')),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('إضافة صورة للتمرين'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              const SizedBox(height: 20),

              // Personal Record
              if (currentPR > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.successGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: AppTheme.successGreen, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الرقم القياسي الشخصي',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${currentPR.toStringAsFixed(1)} كجم',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _startWorkoutSession(BuildContext context, String day) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('بدء جلسة تمرين ${dayInfo[day]!['title']}... 🔥'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }
}
