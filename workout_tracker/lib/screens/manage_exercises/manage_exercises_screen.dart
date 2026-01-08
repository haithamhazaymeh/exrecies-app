import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/exercise.dart';
import '../../theme/app_theme.dart';
import '../../services/image_service.dart';
import 'dart:io';

class ManageExercisesScreen extends StatelessWidget {
  const ManageExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التمارين'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          final exercises = provider.exercises;
          
          if (exercises.isEmpty) {
            return const Center(
              child: Text('لا توجد تمارين'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(exercise.category),
                    child: Icon(
                      _getCategoryIcon(exercise.category),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${exercise.targetSets} مجموعات × ${exercise.targetReps}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: AppTheme.primaryBlue,
                        onPressed: () => _editExercise(context, exercise),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: AppTheme.accentRed,
                        onPressed: () => _deleteExercise(context, provider, exercise),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addExercise(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة تمرين'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'kegel':
      case 'posture':
        return AppTheme.secondaryOrange;
      case 'chest':
      case 'back':
        return AppTheme.primaryBlue;
      case 'legs':
        return AppTheme.successGreen;
      case 'biceps':
      case 'triceps':
        return const Color(0xFF8b5cf6);
      case 'shoulders':
        return AppTheme.accentRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'kegel':
      case 'posture':
        return Icons.accessibility_new;
      case 'chest':
      case 'back':
        return Icons.fitness_center;
      case 'legs':
        return Icons.directions_run;
      case 'biceps':
      case 'triceps':
        return Icons.sports_martial_arts;
      case 'shoulders':
        return Icons.airline_seat_recline_extra;
      default:
        return Icons.sports;
    }
  }

  void _addExercise(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseFormScreen(),
      ),
    );
  }

  void _editExercise(BuildContext context, Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseFormScreen(exercise: exercise),
      ),
    );
  }

  void _deleteExercise(BuildContext context, WorkoutProvider provider, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التمرين'),
        content: Text('هل تريد حذف "${exercise.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteExercise(exercise.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم الحذف'),
                  backgroundColor: AppTheme.accentRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

// ==================== نموذج إضافة/تعديل التمرين ====================

class ExerciseFormScreen extends StatefulWidget {
  final Exercise? exercise;

  const ExerciseFormScreen({super.key, this.exercise});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _descArController;
  late TextEditingController _descEnController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _targetMuscleController;
  
  String _type = 'morning';
  String? _day;
  String _category = 'posture';
  String _difficulty = 'متوسط';
  
  File? _selectedImage;
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    _nameArController = TextEditingController(text: ex?.nameAr ?? '');
    _nameEnController = TextEditingController(text: ex?.nameEn ?? '');
    _descArController = TextEditingController(text: ex?.descriptionAr ?? '');
    _descEnController = TextEditingController(text: ex?.descriptionEn ?? '');
    _setsController = TextEditingController(text: ex?.targetSets.toString() ?? '3');
    _repsController = TextEditingController(text: ex?.targetReps ?? '10');
    _targetMuscleController = TextEditingController(text: ex?.targetMuscle ?? '');
    
    if (ex != null) {
      _type = ex.type;
      _day = ex.day;
      _category = ex.category;
      _difficulty = ex.difficulty ?? 'متوسط';
      _currentImagePath = ex.imagePath;
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _targetMuscleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'إضافة تمرين' : 'تعديل تمرين'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameArController,
              decoration: const InputDecoration(
                labelText: 'الاسم بالعربي *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameEnController,
              decoration: const InputDecoration(
                labelText: 'الاسم بالإنجليزي',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descArController,
              decoration: const InputDecoration(
                labelText: 'الوصف بالعربي *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descEnController,
              decoration: const InputDecoration(
                labelText: 'الوصف بالإنجليزي',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setsController,
                    decoration: const InputDecoration(
                      labelText: 'المجموعات *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _repsController,
                    decoration: const InputDecoration(
                      labelText: 'العدات *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetMuscleController,
              decoration: const InputDecoration(
                labelText: 'العضلة المستهدفة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'النوع',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'morning', child: Text('صباحي')),
                DropdownMenuItem(value: 'gym', child: Text('نادي')),
              ],
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(
                labelText: 'الصعوبة',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'سهل', child: Text('سهل')),
                DropdownMenuItem(value: 'متوسط', child: Text('متوسط')),
                DropdownMenuItem(value: 'صعب', child: Text('صعب')),
              ],
              onChanged: (value) => setState(() => _difficulty = value!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                padding: const EdgeInsets.all(16),
              ),
              child: Text(widget.exercise == null ? 'إضافة' : 'حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _showImageSourceDialog,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.5)),
            image: _selectedImage != null
                ? DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  )
                : (_currentImagePath != null && _currentImagePath!.isNotEmpty && File(_currentImagePath!).existsSync())
                    ? DecorationImage(
                        image: FileImage(File(_currentImagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
          ),
          child: (_selectedImage == null && (_currentImagePath == null || _currentImagePath!.isEmpty || !File(_currentImagePath!).existsSync()))
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('إضافة صورة', style: TextStyle(color: Colors.grey)),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(bool fromCamera) async {
    try {
      final image = fromCamera
          ? await ImageService.instance.captureImage()
          : await ImageService.instance.pickImageFromGallery();
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
      );
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final exercise = Exercise(
        id: widget.exercise?.id,
        name: _nameArController.text,
        nameAr: _nameArController.text,
        nameEn: _nameEnController.text.isEmpty ? null : _nameEnController.text,
        description: _descArController.text,
        descriptionAr: _descArController.text,
        descriptionEn: _descEnController.text.isEmpty ? null : _descEnController.text,
        type: _type,
        day: _day,
        day: _day,
        targetSets: int.parse(_setsController.text),
        targetReps: _repsController.text,
        imagePath: _selectedImage?.path ?? _currentImagePath,
        category: _category,
        targetMuscle: _targetMuscleController.text.isEmpty ? null : _targetMuscleController.text,
        difficulty: _difficulty,
        equipment: 'بدون معدات',
        orderIndex: widget.exercise?.orderIndex ?? 999,
      );

      final provider = context.read<WorkoutProvider>();
      if (widget.exercise == null) {
        provider.addExercise(exercise);
      } else {
        provider.updateExercise(exercise);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.exercise == null ? 'تم الإضافة!' : 'تم التحديث!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }
}
