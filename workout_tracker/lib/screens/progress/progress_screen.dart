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
  // Controllers for weight entry dialog
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _notesController = TextEditingController();
  }

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
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'متابعة التقدم 📊',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      blurRadius: 12.0,
                      color: Colors.black45,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.successGradient,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.15),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 15),
                        const Icon(
                          Icons.trending_down,
                          size: 70,
                          color: Colors.white30,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'كل كيلو يهم • استمر',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تطور الوزن',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showWeightHistory(context, provider),
                icon: const Icon(Icons.history, size: 18),
                label: const Text('السجل'),
              ),
            ],
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

  void _showWeightHistory(BuildContext context, WorkoutProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'سجل الوزن',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.bodyWeightLogs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = provider.bodyWeightLogs[index];
                    final previousLog = index < provider.bodyWeightLogs.length - 1
                        ? provider.bodyWeightLogs[index + 1]
                        : null;
                    final change = previousLog != null
                        ? log.weight - previousLog.weight
                        : 0.0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  intl.DateFormat('yyyy-MM-dd').format(log.date),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${log.weight.toStringAsFixed(1)} كجم',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (change != 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: change < 0
                                              ? AppTheme.successGreen.withOpacity(0.1)
                                              : AppTheme.accentRed.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: change < 0
                                                ? AppTheme.successGreen
                                                : AppTheme.accentRed,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (log.notes != null && log.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    log.notes!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _editWeightLog(context, log);
                                },
                                icon: const Icon(Icons.edit, size: 20),
                                color: AppTheme.primaryBlue,
                              ),
                              if (provider.bodyWeightLogs.length > 1)
                                IconButton(
                                  onPressed: () {
                                    _deleteWeightLog(context, provider, log);
                                  },
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: AppTheme.accentRed,
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editWeightLog(BuildContext context, BodyWeightLog log) {
    _weightController.text = log.weight.toString();
    _notesController.text = log.notes ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الوزن'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الوزن (كجم)',
                suffixText: 'كجم',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
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
                final updatedLog = log.copyWith(
                  weight: weight,
                  notes: _notesController.text.isEmpty ? null : _notesController.text,
                );
                
                context.read<WorkoutProvider>().updateBodyWeightLog(updatedLog);
                _weightController.clear();
                _notesController.clear();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث الوزن! ✅'),
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

  void _deleteWeightLog(BuildContext context, WorkoutProvider provider, BodyWeightLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف القياس'),
        content: Text(
          'هل تريد حذف قياس ${log.weight.toStringAsFixed(1)} كجم؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (log.id != null) {
                provider.deleteBodyWeightLog(log.id!);
                Navigator.pop(context);
                Navigator.pop(context); // Close history sheet
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم الحذف'),
                    backgroundColor: AppTheme.accentRed,
                  ),
                );
              }
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
