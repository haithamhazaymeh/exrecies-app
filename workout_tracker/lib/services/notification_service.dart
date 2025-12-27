import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // معالجة النقر على الإشعار
      },
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'workout_channel',
      'Workout Notifications',
      channelDescription: 'إشعارات التمارين الرياضية',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_workout_channel',
          'Daily Workout Reminders',
          channelDescription: 'تذكيرات يومية للتمارين',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> scheduleWorkoutReminders() async {
    // روتين الصباح - 6:00 صباحاً
    await scheduleDailyNotification(
      id: 1,
      title: '☀️ وقت روتين الصباح!',
      body: 'حان وقت تمارين كيجل والقوام - 20 دقيقة فقط! 💪',
      hour: 6,
      minute: 0,
    );

    // تذكير النادي - 5:00 مساءً
    await scheduleDailyNotification(
      id: 2,
      title: '🏋️ وقت النادي يا بطل!',
      body: 'استعد لتمرين اليوم - جسمك يستحق هذا الاهتمام! 🔥',
      hour: 17,
      minute: 0,
    );

    // تذكير تسجيل الوزن - كل أسبوع السبت 8:00 صباحاً
    await scheduleDailyNotification(
      id: 3,
      title: '⚖️ وقت قياس الوزن!',
      body: 'لا تنسى تسجيل وزنك اليوم لمتابعة تقدمك 📊',
      hour: 8,
      minute: 0,
    );
  }

  Future<void> scheduleMotivationalNotifications() async {
    final messages = NotificationMessages.motivational;
    
    for (int i = 0; i < messages.length; i++) {
      await scheduleDailyNotification(
        id: 100 + i,
        title: '💪 رسالة تحفيزية',
        body: messages[i],
        hour: 12 + (i % 6), // توزيع الرسائل على مدار اليوم
        minute: 0,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}

class NotificationMessages {
  static const List<String> motivational = [
    'وقت التمرين يا بطل! 💪',
    'جسمك يستحق هذا الاهتمام 🏋️',
    'خطوة واحدة أقرب للهدف! 🎯',
    'لا تستسلم، أنت قوي! 🔥',
    'كل تمرين يقربك من حلمك 💎',
    'اليوم أفضل من الأمس! 🌟',
    'قوتك في إرادتك! ⚡',
    'الألم مؤقت، الفخر أبدي! 🏆',
    'أنت أقوى مما تظن! 💯',
    'استمر، النتائج قادمة! 🚀',
    'جسد صحي، عقل سليم! 🧠',
    'لا عذر اليوم، فقط إنجاز! ✨',
    'الزفاف قريب، الهدف واضح! 💍',
    '80 كجم هدف قابل للتحقيق! 📈',
    'كل مجموعة تقربك من النجاح! 🎖️',
  ];

  static const List<String> achievements = [
    '🎉 مبروك! أكملت أسبوع كامل!',
    '🔥 أنت في المسار الصحيح!',
    '💪 تقدم ملحوظ هذا الشهر!',
    '⭐ رقم قياسي جديد!',
    '🏆 إنجاز رائع اليوم!',
  ];

  static const List<String> reminders = [
    '💧 لا تنسى شرب الماء!',
    '🥗 التغذية الصحية مهمة!',
    '😴 النوم الكافي ضروري للبناء!',
    '🧘 استرخِ واعتني بنفسك!',
  ];
}
