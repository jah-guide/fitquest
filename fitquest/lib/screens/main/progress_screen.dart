import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fitquest/locale/app_localizations.dart';
import '../../models/workout_session.dart';
import '../../services/workout_session_service.dart';
import 'workout_timer_screen.dart';

enum _ProgressRange { last7Days, last30Days, allTime }

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final WorkoutSessionService _sessionService = WorkoutSessionService();
  bool _isLoading = true;
  String? _loadError;
  _ProgressRange _selectedRange = _ProgressRange.last7Days;
  List<WorkoutSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _sessionService.getSessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sessions = [];
        _loadError = 'Unable to load your progress right now.';
        _isLoading = false;
      });
    }
  }

  Future<void> _startWorkoutFromProgress() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutTimerScreen()),
    );
    if (saved == true) {
      await _loadSessions();
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    }
    return '${minutes}m ${secs}s';
  }

  int _rangeInDays() {
    switch (_selectedRange) {
      case _ProgressRange.last7Days:
        return 7;
      case _ProgressRange.last30Days:
        return 30;
      case _ProgressRange.allTime:
        return 90;
    }
  }

  String _rangeLabel() {
    switch (_selectedRange) {
      case _ProgressRange.last7Days:
        return 'Last 7 Days';
      case _ProgressRange.last30Days:
        return 'Last 30 Days';
      case _ProgressRange.allTime:
        return 'All Time';
    }
  }

  List<WorkoutSession> _filteredSessions() {
    if (_selectedRange == _ProgressRange.allTime) {
      return _sessions;
    }

    final days = _rangeInDays();
    final threshold = DateTime.now().subtract(Duration(days: days));
    return _sessions.where((s) => s.endedAt.isAfter(threshold)).toList();
  }

  Map<DateTime, int> _minutesByDayForRange(List<WorkoutSession> sessions) {
    final now = DateTime.now();
    final numberOfDays = _rangeInDays();

    final days = List.generate(numberOfDays, (index) {
      final day = now.subtract(Duration(days: numberOfDays - 1 - index));
      return DateTime(day.year, day.month, day.day);
    });

    final map = {for (final day in days) day: 0};
    for (final session in sessions) {
      final day = DateTime(
        session.endedAt.year,
        session.endedAt.month,
        session.endedAt.day,
      );
      if (map.containsKey(day)) {
        map[day] = map[day]! + (session.durationSeconds ~/ 60);
      }
    }
    return map;
  }

  int _longestSessionSeconds() {
    final sessions = _filteredSessions();
    if (sessions.isEmpty) return 0;
    return sessions
        .map((e) => e.durationSeconds)
        .reduce((value, element) => value > element ? value : element);
  }

  int _currentStreakDays() {
    final sessions = _filteredSessions();
    if (sessions.isEmpty) return 0;

    final uniqueDays =
        sessions
            .map(
              (e) => DateTime(e.endedAt.year, e.endedAt.month, e.endedAt.day),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    var streak = 0;

    final containsToday = uniqueDays.any((d) => d == cursor);
    if (!containsToday) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (uniqueDays.any((d) => d == cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _totalSets(WorkoutSession session) {
    return session.exerciseLogs.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );
  }

  int _totalReps(WorkoutSession session) {
    return session.exerciseLogs.fold<int>(
      0,
      (sum, exercise) =>
          sum + exercise.sets.fold<int>(0, (setSum, set) => setSum + set.reps),
    );
  }

  double? _averageRpe(WorkoutSession session) {
    final values = session.exerciseLogs
        .expand((exercise) => exercise.sets)
        .map((set) => set.rpe)
        .whereType<double>()
        .toList();

    if (values.isEmpty) return null;
    final total = values.reduce((a, b) => a + b);
    return total / values.length;
  }

  void _showExportSummary() {
    final sessions = _filteredSessions();
    final totalSeconds = sessions.fold<int>(
      0,
      (sum, item) => sum + item.durationSeconds,
    );
    final avgSeconds = sessions.isEmpty ? 0 : (totalSeconds ~/ sessions.length);

    final summary = StringBuffer()
      ..writeln('FitQuest Progress Summary')
      ..writeln('Period: ${_rangeLabel()}')
      ..writeln('Workouts: ${sessions.length}')
      ..writeln('Total Minutes: ${totalSeconds ~/ 60}')
      ..writeln('Average Session: ${_formatDuration(avgSeconds)}')
      ..writeln('Current Streak: ${_currentStreakDays()} days')
      ..writeln(
        'Longest Session: ${_formatDuration(_longestSessionSeconds())}',
      );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(summary.toString()),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: summary.toString()),
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Summary copied to clipboard.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy Summary'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final sessions = _filteredSessions();
    final totalSeconds = sessions.fold<int>(
      0,
      (sum, item) => sum + item.durationSeconds,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.progress),
        actions: [
          IconButton(
            tooltip: 'Export summary',
            onPressed: _sessions.isEmpty ? null : _showExportSummary,
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        setState(() => _isLoading = true);
                        _loadSessions();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : sessions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insights_outlined,
                      size: 38,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No workouts logged yet. Start a timer to track your first session.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _startWorkoutFromProgress,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(loc.startWorkout),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SegmentedButton<_ProgressRange>(
                    segments: const [
                      ButtonSegment(
                        value: _ProgressRange.last7Days,
                        label: Text('7D'),
                      ),
                      ButtonSegment(
                        value: _ProgressRange.last30Days,
                        label: Text('30D'),
                      ),
                      ButtonSegment(
                        value: _ProgressRange.allTime,
                        label: Text('All'),
                      ),
                    ],
                    selected: {_selectedRange},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _selectedRange = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Performance Overview • ${_rangeLabel()}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildKpiCard(
                    title: 'Total Workouts',
                    value: sessions.length.toString(),
                    icon: Icons.fitness_center,
                  ),
                  _buildKpiCard(
                    title: 'Total Minutes',
                    value: (totalSeconds ~/ 60).toString(),
                    icon: Icons.timer,
                  ),
                  _buildKpiCard(
                    title: 'Average Duration',
                    value: _formatDuration(totalSeconds ~/ sessions.length),
                    icon: Icons.analytics_outlined,
                  ),
                  _buildKpiCard(
                    title: 'Current Streak',
                    value: '${_currentStreakDays()} days',
                    icon: Icons.local_fire_department_outlined,
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Minutes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: Builder(
                              builder: (context) {
                                final data = _minutesByDayForRange(
                                  sessions,
                                ).entries.toList();
                                final maxY = data
                                    .map((e) => e.value.toDouble())
                                    .reduce((a, b) => a > b ? a : b);

                                return BarChart(
                                  BarChartData(
                                    minY: 0,
                                    maxY: maxY <= 0 ? 5 : maxY + 5,
                                    gridData: const FlGridData(
                                      drawVerticalLine: false,
                                    ),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 34,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index < 0 ||
                                                index >= data.length) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                              ),
                                              child: Text(
                                                _selectedRange ==
                                                        _ProgressRange.last7Days
                                                    ? DateFormat(
                                                        'E',
                                                      ).format(data[index].key)
                                                    : DateFormat(
                                                        'd MMM',
                                                      ).format(data[index].key),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    barGroups: List.generate(data.length, (
                                      index,
                                    ) {
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: data[index].value.toDouble(),
                                            width: 18,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Session Duration Trend',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: Builder(
                              builder: (context) {
                                final recent = sessions
                                    .take(7)
                                    .toList()
                                    .reversed
                                    .toList();

                                final spots = List.generate(recent.length, (i) {
                                  return FlSpot(
                                    i.toDouble(),
                                    (recent[i].durationSeconds / 60),
                                  );
                                });

                                final maxY = spots.isEmpty
                                    ? 10.0
                                    : spots
                                              .map((s) => s.y)
                                              .reduce((a, b) => a > b ? a : b) +
                                          5;

                                return LineChart(
                                  LineChartData(
                                    minY: 0,
                                    maxY: maxY,
                                    gridData: const FlGridData(
                                      drawVerticalLine: false,
                                    ),
                                    borderData: FlBorderData(show: false),
                                    titlesData: const FlTitlesData(
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: true),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Recent Sessions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...sessions
                      .take(10)
                      .map(
                        (session) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.timer_outlined),
                            title: Text(
                              _formatDuration(session.durationSeconds),
                            ),
                            subtitle: Text(
                              [
                                DateFormat(
                                  'EEE, dd MMM yyyy • HH:mm',
                                ).format(session.endedAt),
                                if ((session.routineName ?? '').isNotEmpty)
                                  'Routine: ${session.routineName}',
                                if (_totalSets(session) > 0)
                                  'Sets: ${_totalSets(session)} • Reps: ${_totalReps(session)}${_averageRpe(session) != null ? ' • Avg RPE: ${_averageRpe(session)!.toStringAsFixed(1)}' : ''}',
                              ].join('\n'),
                            ),
                            trailing: Text(
                              'Peak: ${_formatDuration(_longestSessionSeconds())}',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}
