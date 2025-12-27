import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart' as intl;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<WorkoutProvider>().loadAllData(),
        child: CustomScrollView(
          slivers: [
            // AppBar محسّن مع تدرج
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  'رحلتك إلى 80 كجم 🔥',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        blurRadius: 15.0,
                        color: Colors.black45,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient Background
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                    ),
                    // Overlay Pattern
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                    // Center Icon
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Icon(
                            Icons.fitness_center,
                            size: 100,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'البداية • التحدي • النجاح',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // المحتوى
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // بطاقة التقدم الرئيسية
                  _buildProgressCard(context),
                  const SizedBox(height: 16),

                  // الإحصائيات السريعة
                  _buildQuickStats(context),
                  const SizedBox(height: 16),

                  // الإجراءات السريعة
                  _buildQuickActions(context),
                  const SizedBox(height: 16),

                  // التمرين القادم
                  _buildNextWorkout(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final latestWeight = provider.latestBodyWeight;
        final progress = provider.getProgressPercentage();
        final remaining = provider.getRemainingWeight();

        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.orangeGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryOrange.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                '🎯 الهدف: 80 كجم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // عرض الوزن الحالي
              if (latestWeight != null) ...[
                Text(
                  '${latestWeight.weight.toStringAsFixed(1)} كجم',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'الوزن الحالي',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),

                // شريط التقدم
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 12,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  '${progress.toStringAsFixed(1)}% مكتمل | ${remaining.toStringAsFixed(1)} كجم متبقي',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.monitor_weight,
                  size: 64,
                  color: Colors.white70,
                ),
                const SizedBox(height: 12),
                const Text(
                  'لم يتم تسجيل الوزن بعد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // الانتقال لصفحة تسجيل الوزن
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('سجل وزنك الآن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.secondaryOrange,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<int>(
          future: provider.getWorkoutCountThisMonth(),
          builder: (context, snapshot) {
            final workoutCount = snapshot.data ?? 0;
            
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.fitness_center,
                    title: 'تمارين هذا الشهر',
                    value: '$workoutCount',
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    title: 'السلسلة الحالية',
                    value: '🔥 ${_getStreak()}',
                    color: AppTheme.accentRed,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12, right: 8),
          child: Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context: context,
                label: 'روتين الصباح',
                icon: Icons.wb_sunny,
                color: AppTheme.secondaryOrange,
                onTap: () => Navigator.pushNamed(context, '/morning'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context: context,
                label: 'تمارين النادي',
                icon: Icons.fitness_center,
                color: AppTheme.primaryBlue,
                onTap: () => Navigator.pushNamed(context, '/gym'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextWorkout(BuildContext context) {
    final dayNames = {
      'day1': 'اليوم الأول: علوي (صدر + ظهر)',
      'day2': 'اليوم الثاني: أرجل',
      'day3': 'اليوم الثالث: ذراعين',
      'day4': 'اليوم الرابع: أكتاف + كور',
    };

    final today = DateTime.now();
    final dayOfWeek = today.weekday; // 1 = Monday
    String nextDay = 'day1';
    
    if (dayOfWeek >= 1 && dayOfWeek <= 4) {
      nextDay = 'day$dayOfWeek';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.today, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'التمرين القادم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dayNames[nextDay] ?? 'روتين الصباح',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/gym', arguments: nextDay);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryBlue,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('ابدأ التمرين'),
          ),
        ],
      ),
    );
  }

  int _getStreak() {
    // TODO: حساب السلسلة من قاعدة البيانات
    return 3;
  }
}
