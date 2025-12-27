import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'providers/workout_provider.dart';
import 'services/notification_service.dart';
import 'database/database_helper.dart';
import 'data/initial_exercises.dart';
import 'screens/home/home_screen.dart';
import 'screens/morning_routine/morning_routine_screen.dart';
import 'screens/gym/gym_schedule_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة الإشعارات
  await NotificationService.instance.initialize();
  
  // تهيئة القاعدة وإضافة البيانات الأولية إذا لزم الأمر
  await _initializeDatabase();
  
  // تعيين اتجاه الشاشة للعمودي فقط
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

Future<void> _initializeDatabase() async {
  // SQLite لا يعمل على الويب - نتجاهله في وضع المعاينة
  try {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('is_first_run') ?? true;

    if (isFirstRun) {
      // إضافة التمارين الأولية
      final db = DatabaseHelper.instance;
      for (var exercise in InitialExercises.getAllExercises()) {
        await db.insertExercise(exercise);
      }
      
      await prefs.setBool('is_first_run', false);
      
      // جدولة الإشعارات
      await NotificationService.instance.scheduleWorkoutReminders();
    }
  } catch (e) {
    // في حالة الويب، نتجاهل أخطاء قاعدة البيانات
    print('تحذير: قاعدة البيانات غير متاحة (يحدث هذا على الويب) - الواجهة ستعمل بدون بيانات');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider()..loadAllData(),
      child: MaterialApp(
        title: 'برنامج التحول البدني',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        
        // الصفحة الرئيسية
        routes: {
          '/manage-exercises': (context) => const ManageExercisesScreen(),
        },
        home: const MainNavigationScreen(),
        
        // المسارات
        routes: {
          '/morning': (context) => const MorningRoutineScreen(),
          '/gym': (context) => const GymScheduleScreen(),
          '/progress': (context) => const ProgressScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MorningRoutineScreen(),
    GymScheduleScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'الرئيسية',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.wb_sunny),
      label: 'الصباح',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.fitness_center),
      label: 'النادي',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.trending_up),
      label: 'التقدم',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'الإعدادات',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: _navItems,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
