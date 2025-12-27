import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/body_weight_log.dart';
import 'package:intl/intl.dart' as intl;

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
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
                '📊 متابعة التقدم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.successGreen, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          Consumer<WorkoutProvider>(
            builder: (context, provider, child) {
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Current weight and target
                    _buildWeightSummary(provider),
                    const SizedBox(height: 20),

                    // Weight chart
                    _buildWeightChart(provider),
                    const SizedBox(height: 20),

                    // Progress table
                    _buildProgressTable(provider),
                    const SizedBox(height: 20),

                    // Workout stats
                    _buildWorkoutStats(provider),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddWeightDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('تسجيل الوزن'),
      ),
    );
  }

  Widget _buildWeightSummary(WorkoutProvider provider) {
    final latestWeight = provider.latestBodyWeight;
    final progress = provider.getProgressPercentage();
    final remaining = provider.getRemainingWeight();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الوزن الحالي',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Text(
                'الهدف: 80 كجم',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (latestWeight != null) ...[
            Text(
              '${latestWeight.weight.toStringAsFixed(1)} كجم',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'متبقي: ${remaining.toStringAsFixed(1)} كجم',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 14,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${progress.toStringAsFixed(1)}% من الهدف مكتمل 🎯',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            const Text(
              'لم يتم تسجيل الوزن بعد',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddWeightDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('سجل وزنك الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightChart(WorkoutProvider provider) {
    final weightLogs = provider.bodyWeightLogs.reversed.take(10).toList();

    if (weightLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
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
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.show_chart, size: 64, color: AppTheme.textSecondary),
              SizedBox(height: 16),
              Text(
                'سجل وزنك لعرض الرسم البياني',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

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
          const Text(
            'تطور الوزن',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weightLogs
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.primaryBlue,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                    ),
                  ),
                  // Target line
                  LineChartBarData(
                    spots: List.generate(
                      weightLogs.length,
                      (index) => FlSpot(index.toDouble(), 80),
                    ),
                    isCurved: false,
                    color: AppTheme.successGreen,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTable(WorkoutProvider provider) {
    final milestones = [
      {'week': 'البداية', 'expected': '93', 'status': 'بدأت القوية'},
      {'week': 'الأسبوع 4', 'expected': '89', 'status': 'تنشيف أولي'},
      {'week': 'الأسبوع 8', 'expected': '85', 'status': 'تحسن القوام'},
      {'week': 'موعد الزفاف', 'expected': '80-82', 'status': 'مبروك يا عريس!'},
    ];

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
          const Text(
            'جدول التقدم المتوقع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            children: [
              TableRow(
                decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1)),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('المرحلة', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('الوزن المتوقع', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              ...milestones.map((milestone) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(milestone['week']!),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${milestone['expected']} كجم'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        milestone['status']!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats(WorkoutProvider provider) {
    return FutureBuilder<int>(
      future: provider.getWorkoutCountThisMonth(),
      builder: (context, snapshot) {
        final workoutCount = snapshot.data ?? 0;

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
              const Text(
                'إحصائيات التمارين',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('🏋️', workoutCount.toString(), 'تمارين هذا الشهر'),
                  _statItem('🔥', '3', 'أيام متتالية'),
                  _statItem('💪', provider.exercises.length.toString(), 'إجمالي التمارين'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الوزن'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الوزن (كجم)',
                hintText: '93.5',
                suffixText: 'كجم',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: 'مثال: شعور جيد اليوم',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(_weightController.text);
              if (weight != null) {
                final log = BodyWeightLog(
                  date: DateTime.now(),
                  weight: weight,
                  notes: _notesController.text.isEmpty ? null : _notesController.text,
                );

                context.read<WorkoutProvider>().addBodyWeightLog(log);
                _weightController.clear();
                _notesController.clear();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الوزن بنجاح! ✅'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
