import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';
import '../manage_exercises/manage_exercises_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _morningReminderEnabled = true;
  bool _gymReminderEnabled = true;
  bool _weightReminderEnabled = true;
  bool _motivationalNotifications = true;

  TimeOfDay _morningTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _gymTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _morningReminderEnabled = prefs.getBool('morning_reminder') ?? true;
      _gymReminderEnabled = prefs.getBool('gym_reminder') ?? true;
      _weightReminderEnabled = prefs.getBool('weight_reminder') ?? true;
      _motivationalNotifications = prefs.getBool('motivational_notif') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    if (value) {
      await NotificationService.instance.scheduleWorkoutReminders();
    } else {
      await NotificationService.instance.cancelAllNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '⚙️ الإعدادات',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Notification settings
                _buildSectionHeader('🔔 الإشعارات'),
                const SizedBox(height: 12),
                _buildNotificationCard(),
                const SizedBox(height: 24),

                // Additional Info
                _buildSectionHeader('ℹ️ معلومات إضافية'),
                const SizedBox(height: 12),
                _buildInfoCard(),
                const SizedBox(height: 24),

                // About
                _buildSectionHeader('📱 حول التطبيق'),
                const SizedBox(height: 12),
                _buildAboutCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('تذكير روتين الصباح'),
              subtitle: Text('${_morningTime.hour}:${_morningTime.minute.toString().padLeft(2, '0')} صباحاً'),
              value: _morningReminderEnabled,
              onChanged: (value) async {
                setState(() {
                  _morningReminderEnabled = value;
                });
                await _saveSetting('morning_reminder', value);
              },
              secondary: const Icon(Icons.wb_sunny, color: AppTheme.secondaryOrange),
            ),
            const Divider(),

            SwitchListTile(
              title: const Text('تذكير تمارين النادي'),
              subtitle: Text('${_gymTime.hour}:${_gymTime.minute.toString().padLeft(2, '0')} مساءً'),
              value: _gymReminderEnabled,
              onChanged: (value) async {
                setState(() {
                  _gymReminderEnabled = value;
                });
                await _saveSetting('gym_reminder', value);
              },
              secondary: const Icon(Icons.fitness_center, color: AppTheme.primaryBlue),
            ),
            const Divider(),

            SwitchListTile(
              title: const Text('تذكير قياس الوزن'),
              subtitle: const Text('كل أسبوع - يوم السبت'),
              value: _weightReminderEnabled,
              onChanged: (value) async {
                setState(() {
                  _weightReminderEnabled = value;
                });
                await _saveSetting('weight_reminder', value);
              },
              secondary: const Icon(Icons.monitor_weight, color: AppTheme.successGreen),
            ),
            const Divider(),

            SwitchListTile(
              title: const Text('رسائل تحفيزية'),
              subtitle: const Text('رسائل يومية للتحفيز'),
              value: _motivationalNotifications,
              onChanged: (value) async {
                setState(() {
                  _motivationalNotifications = value;
                });
                await _saveSetting('motivational_notif', value);
                
                if (value) {
                  await NotificationService.instance.scheduleMotivationalNotifications();
                }
              },
              secondary: const Icon(Icons.favorite, color: AppTheme.accentRed),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tips_and_updates, color: AppTheme.secondaryOrange),
            ),
            title: const Text('نصائح التغذية'),
            subtitle: const Text('دليل شامل للتغذية الصحية'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              _showNutritionTipsDialog();
            },
          ),
          const Divider(height: 1),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_fire_department, color: AppTheme.accentRed),
            ),
            title: const Text('إدارة حساسية الحرارة'),
            subtitle: const Text('نصائح للتعامل مع الحرارة'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              _showHeatManagementDialog();
            },
          ),
          const Divider(height: 1),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.desk, color: AppTheme.primaryBlue),
            ),
            title: const Text('نصائح العمل المكتبي'),
            subtitle: const Text('تقليل آلام الرقبة والظهر'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              _showOfficeWorkTipsDialog();
            },
          ),
          const Divider(height: 1),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_note, color: AppTheme.primaryBlue),
            ),
            title: const Text('إدارة التمارين'),
            subtitle: const Text('إضافة وتعديل وحذف التمارين'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageExercisesScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.orangeGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'برنامج التحول البدني',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '💍 خطة "الزفاف" للتحول البدني',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'الهدف: وزن 80 كجم | جسم ناشف | قوام مستقيم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNutritionTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نصائح التغذية 🥗'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tipItem('🍗 البروتين', 'صدور دجاج، تونة، بيض، سمك'),
              _tipItem('🍚 الكربوهيدرات', 'شوفان، أرز أسمر، بطاطس مسلوقة'),
              _tipItem('❌ ممنوعات', 'السكر، المشروبات الغازية، المقليات'),
              _tipItem('💧 الماء', '4 لتر يومياً (1 لتر لكل 25 كجم)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showHeatManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدارة حساسية الحرارة 🔥'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tipItem('💧', 'اشرب 1 لتر ماء لكل 25 كيلو من وزنك'),
              _tipItem('🧊', 'استخدم منشفة مبللة بماء بارد على الرقبة'),
              _tipItem('🚶', 'المشي المنحدر أفضل من الجري للتعرق الأقل'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showOfficeWorkTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نصائح العمل المكتبي 💼'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tipItem('👁️', 'قاعدة 20-20-20: كل 20 دقيقة انظر لمسافة بعيدة'),
              _tipItem('🖥️', 'اجعل الشاشة في مستوى عينيك'),
              _tipItem('🚶', 'قف وتحرك لمدة دقيقتين كل ساعة'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Widget _tipItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
