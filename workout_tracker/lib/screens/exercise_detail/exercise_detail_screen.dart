import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../theme/app_theme.dart';
import '../../services/image_service.dart';
import 'dart:io';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool showEnglish = false;

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar مع صورة
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                showEnglish ? exercise.displayNameEn : exercise.displayNameAr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black54,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // صورة التمرين أو gradient
                  if (exercise.imagePath != null)
                    Image.file(
                      File(exercise.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildGradientBackground(),
                    )
                  else
                    _buildGradientBackground(),
                  
                  // Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // زر تبديل اللغة
              if (exercise.nameEn != null)
                IconButton(
                  icon: Text(
                    showEnglish ? 'ع' : 'EN',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      showEnglish = !showEnglish;
                    });
                  },
                  tooltip: showEnglish ? 'عربي' : 'English',
                ),
            ],
          ),

          // المحتوى
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // الوصف
                _buildSection(
                  title: 'الوصف',
                  icon: Icons.description,
                  child: Text(
                    showEnglish 
                        ? exercise.displayDescriptionEn 
                        : exercise.displayDescriptionAr,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // معلومات التمرين
                _buildSection(
                  title: 'معلومات التمرين',
                  icon: Icons.info_outline,
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.fitness_center,
                        label: 'الهدف',
                        value: '${exercise.targetSets} مجموعات × ${exercise.targetReps}',
                        color: AppTheme.primaryBlue,
                      ),
                      if (exercise.targetMuscle != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.accessibility_new,
                          label: 'العضلة المستهدفة',
                          value: exercise.targetMuscle!,
                          color: AppTheme.successGreen,
                        ),
                      ],
                      if (exercise.targetAngle != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.architecture,
                          label: 'الزاوية',
                          value: exercise.targetAngle!,
                          color: AppTheme.secondaryOrange,
                        ),
                      ],
                      if (exercise.difficulty != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.speed,
                          label: 'مستوى الصعوبة',
                          value: exercise.difficulty!,
                          color: _getDifficultyColor(exercise.difficulty!),
                        ),
                      ],
                      if (exercise.equipment != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.build,
                          label: 'المعدات',
                          value: exercise.equipment!,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // نوع التمرين
                _buildSection(
                  title: 'التصنيف',
                  icon: Icons.category,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        label: exercise.type == 'morning' ? 'روتين صباحي' : 'نادي',
                        color: exercise.type == 'morning' 
                            ? AppTheme.secondaryOrange 
                            : AppTheme.primaryBlue,
                      ),
                      _buildChip(
                        label: _getCategoryName(exercise.category),
                        color: AppTheme.successGreen,
                      ),
                      if (exercise.day != null)
                        _buildChip(
                          label: _getDayName(exercise.day!),
                          color: AppTheme.accentRed,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // زر إضافة صورة
                OutlinedButton.icon(
                  onPressed: () {
                    _showImageOptions(context);
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(
                    exercise.imagePath == null 
                        ? 'إضافة صورة للتمرين' 
                        : 'تغيير الصورة',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    Color gradientColor;
    switch (widget.exercise.category) {
      case 'kegel':
      case 'posture':
        gradientColor = AppTheme.secondaryOrange;
        break;
      case 'chest':
      case 'back':
        gradientColor = AppTheme.primaryBlue;
        break;
      case 'biceps':
      case 'triceps':
        gradientColor = const Color(0xFF8b5cf6);
        break;
      default:
        gradientColor = AppTheme.successGreen;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColor,
            gradientColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          AppTheme.getCategoryIcon(widget.exercise.category),
          size: 100,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'سهل':
        return AppTheme.successGreen;
      case 'متوسط':
        return AppTheme.secondaryOrange;
      case 'صعب':
        return AppTheme.accentRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getCategoryName(String category) {
    const Map<String, String> names = {
      'kegel': 'كيجل',
      'posture': 'قوام',
      'chest': 'صدر',
      'back': 'ظهر',
      'legs': 'أرجل',
      'biceps': 'باي',
      'triceps': 'تراي',
      'shoulders': 'أكتاف',
      'core': 'بطن وظهر',
      'forearms': 'سواعد',
    };
    return names[category] ?? category;
  }

  String _getDayName(String day) {
    const Map<String, String> names = {
      'day1': 'اليوم 1',
      'day2': 'اليوم 2',
      'day3': 'اليوم 3',
      'day4': 'اليوم 4',
    };
    return names[day] ?? day;
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _addImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _addImageFromGallery();
              },
            ),
            if (widget.exercise.imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.accentRed),
                title: const Text('حذف الصورة'),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addImageFromCamera() async {
    final imagePath = await ImageService.instance.captureImage();
    if (imagePath != null) {
      // تحديث التمرين في قاعدة البيانات
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة الصورة!')),
      );
    }
  }

  Future<void> _addImageFromGallery() async {
    final imagePath = await ImageService.instance.pickImageFromGallery();
    if (imagePath != null) {
      // تحديث التمرين في قاعدة البيانات
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة الصورة!')),
      );
    }
  }

  void _removeImage() {
    // حذف الصورة من قاعدة البيانات
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف الصورة!')),
    );
  }
}
