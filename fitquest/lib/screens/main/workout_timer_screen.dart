import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/workout_session.dart';
import '../../services/api_service.dart';
import '../../services/workout_session_service.dart';

class WorkoutTimerScreen extends StatefulWidget {
  const WorkoutTimerScreen({super.key});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  final WorkoutSessionService _sessionService = WorkoutSessionService();
  final ApiService _api = ApiService();
  final ValueNotifier<int> _elapsedSeconds = ValueNotifier<int>(0);

  Timer? _ticker;
  DateTime? _startedAt;
  bool _isSaving = false;
  bool _isLoadingRoutines = true;
  List<Map<String, dynamic>> _routines = [];
  String? _selectedRoutineId;
  Map<String, dynamic>? _selectedRoutine;
  List<Map<String, dynamic>> _exerciseLogs = [];

  @override
  void initState() {
    super.initState();
    // Deferred so the first frame renders immediately (avoids pumpAndSettle
    // hangs in widget tests when no backend is reachable).
    Future.microtask(_loadRoutines);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    _elapsedSeconds.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds.value = _stopwatch.elapsed.inSeconds;
    });
  }

  int _safeInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double? _safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  List<Map<String, dynamic>> _coerceListOfMaps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> _loadRoutines() async {
    setState(() => _isLoadingRoutines = true);
    try {
      final res = await _api.getRoutines();
      if (!mounted) return;
      if (res['success'] == true) {
        final routines = _coerceListOfMaps(res['routines']);
        setState(() {
          _routines = routines;
          _isLoadingRoutines = false;
        });
      } else {
        setState(() => _isLoadingRoutines = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingRoutines = false);
    }
  }

  void _onRoutineSelected(String? routineId) {
    if (routineId == null) return;
    final selected = _routines.firstWhere(
      (r) => (r['_id'] ?? r['id'])?.toString() == routineId,
      orElse: () => <String, dynamic>{},
    );
    if (selected.isEmpty) return;

    final exercises = _coerceListOfMaps(selected['exercises']);
    final logs = exercises.asMap().entries.map((entry) {
      final exercise = entry.value;
      final targetReps = _safeInt(exercise['reps']);
      return <String, dynamic>{
        'name': exercise['name']?.toString() ?? 'Exercise ${entry.key + 1}',
        'sets': [
          <String, dynamic>{
            'setNumber': 1,
            'reps': targetReps,
            'weightKg': null,
            'rpe': 7.0,
          },
        ],
      };
    }).toList();

    setState(() {
      _selectedRoutineId = routineId;
      _selectedRoutine = selected;
      _exerciseLogs = logs;
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final sets = _exerciseLogs[exerciseIndex]['sets'] as List<dynamic>;
      final previous = sets.isNotEmpty
          ? Map<String, dynamic>.from(sets.last as Map)
          : <String, dynamic>{};
      sets.add({
        'setNumber': sets.length + 1,
        'reps': _safeInt(previous['reps']),
        'weightKg': _safeDouble(previous['weightKg']),
        'rpe': _safeDouble(previous['rpe']) ?? 7.0,
      });
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      final sets = _exerciseLogs[exerciseIndex]['sets'] as List<dynamic>;
      if (sets.length <= 1) return;
      sets.removeAt(setIndex);
      for (var i = 0; i < sets.length; i++) {
        (sets[i] as Map<String, dynamic>)['setNumber'] = i + 1;
      }
    });
  }

  void _startWorkout() {
    _startedAt ??= DateTime.now();
    _stopwatch.start();
    _elapsedSeconds.value = _stopwatch.elapsed.inSeconds;
    _startTicker();
    setState(() {});
  }

  void _pauseWorkout() {
    _stopwatch.stop();
    _elapsedSeconds.value = _stopwatch.elapsed.inSeconds;
    setState(() {});
  }

  Future<void> _stopWorkout() async {
    if (_stopwatch.elapsed.inSeconds <= 0 || _startedAt == null) {
      return;
    }

    setState(() => _isSaving = true);

    final endedAt = DateTime.now();

    final exerciseLogs = _exerciseLogs.map((e) {
      final sets = (e['sets'] as List<dynamic>)
          .map((set) => Map<String, dynamic>.from(set as Map))
          .map(
            (set) => WorkoutSetLog(
              setNumber: _safeInt(set['setNumber'], fallback: 1),
              reps: _safeInt(set['reps']),
              weightKg: _safeDouble(set['weightKg']),
              rpe: _safeDouble(set['rpe']),
            ),
          )
          .toList();

      return WorkoutExerciseLog(
        name: e['name']?.toString() ?? 'Exercise',
        sets: sets,
      );
    }).toList();

    final session = WorkoutSession(
      id: endedAt.microsecondsSinceEpoch.toString(),
      startedAt: _startedAt!,
      endedAt: endedAt,
      durationSeconds: _stopwatch.elapsed.inSeconds,
      routineId: (_selectedRoutine?['_id'] ?? _selectedRoutine?['id'])
          ?.toString(),
      routineName: _selectedRoutine?['name']?.toString(),
      exerciseLogs: exerciseLogs,
    );

    await _sessionService.logSession(session);

    _ticker?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    _elapsedSeconds.value = 0;
    _startedAt = null;

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout saved to progress log.')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _stopwatch.isRunning;
    final hasStarted = _startedAt != null;
    final canStop = _elapsedSeconds.value > 0;
    final colorScheme = Theme.of(context).colorScheme;
    final hasRoutineSelected =
        _selectedRoutine != null && _exerciseLogs.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Timer')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _elapsedSeconds,
              builder: (context, elapsedSeconds, _) {
                final progress = (elapsedSeconds / 3600).clamp(0.0, 1.0);
                final elapsedMinutes = elapsedSeconds ~/ 60;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 250,
                          width: 250,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 250,
                                width: 250,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 13,
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatDuration(
                                      Duration(seconds: elapsedSeconds),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      isRunning
                                          ? 'Workout in progress'
                                          : hasStarted
                                          ? 'Workout paused'
                                          : 'Ready to start',
                                      style: TextStyle(
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniStat(
                                context,
                                icon: Icons.timer,
                                label: 'Minutes',
                                value: '$elapsedMinutes',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMiniStat(
                                context,
                                icon: Icons.list_alt_rounded,
                                label: 'Exercises',
                                value: '${_exerciseLogs.length}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            if (!hasStarted)
              FilledButton.icon(
                onPressed: _isSaving ? null : _startWorkout,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Workout'),
              )
            else ...[
              FilledButton.icon(
                onPressed: _isSaving
                    ? null
                    : (isRunning ? _pauseWorkout : _startWorkout),
                icon: Icon(
                  isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(isRunning ? 'Pause' : 'Resume'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSaving || !canStop ? null : _stopWorkout,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.stop_rounded),
                label: const Text('Stop and Save'),
              ),
            ],
            const SizedBox(height: 12),
            _buildRoutineSelectorCard(
              context,
              hasStarted: hasStarted,
              hasRoutineSelected: hasRoutineSelected,
            ),
            const SizedBox(height: 20),
            if (hasRoutineSelected) ...[
              Text(
                'Exercise Log',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              ..._exerciseLogs.asMap().entries.map(
                (entry) => _buildExerciseLogCard(
                  context,
                  exerciseIndex: entry.key,
                  exercise: entry.value,
                  locked: !hasStarted || _isSaving,
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineSelectorCard(
    BuildContext context, {
    required bool hasStarted,
    required bool hasRoutineSelected,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Routine', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  tooltip: 'Refresh routines',
                  onPressed: _isLoadingRoutines ? null : _loadRoutines,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            if (_isLoadingRoutines)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(value: 0.5, minHeight: 3),
              ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedRoutineId,
              decoration: const InputDecoration(labelText: 'Select Routine'),
              items: _routines.map((routine) {
                final id = (routine['_id'] ?? routine['id'])?.toString() ?? '';
                final name = routine['name']?.toString() ?? 'Routine';
                return DropdownMenuItem(value: id, child: Text(name));
              }).toList(),
              onChanged: hasStarted ? null : _onRoutineSelected,
            ),
            if (!hasRoutineSelected)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Choose a routine to unlock professional exercise logging.',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseLogCard(
    BuildContext context, {
    required int exerciseIndex,
    required Map<String, dynamic> exercise,
    required bool locked,
  }) {
    final sets = (exercise['sets'] as List<dynamic>)
        .map((set) => Map<String, dynamic>.from(set as Map))
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise['name']?.toString() ?? 'Exercise',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final set = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text('S${set['setNumber'] ?? (setIndex + 1)}'),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: TextFormField(
                        initialValue: '${set['reps'] ?? 0}',
                        enabled: !locked,
                        decoration: const InputDecoration(labelText: 'Reps'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          _exerciseLogs[exerciseIndex]['sets'][setIndex]['reps'] =
                              int.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: TextFormField(
                        initialValue: set['weightKg']?.toString() ?? '',
                        enabled: !locked,
                        decoration: const InputDecoration(
                          labelText: 'Weight kg',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {
                          _exerciseLogs[exerciseIndex]['sets'][setIndex]['weightKg'] =
                              double.tryParse(value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: set['rpe']?.toString() ?? '7',
                        enabled: !locked,
                        decoration: const InputDecoration(labelText: 'RPE'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {
                          _exerciseLogs[exerciseIndex]['sets'][setIndex]['rpe'] =
                              double.tryParse(value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: locked || sets.length <= 1
                            ? null
                            : () => _removeSet(exerciseIndex, setIndex),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: locked ? null : () => _addSet(exerciseIndex),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
