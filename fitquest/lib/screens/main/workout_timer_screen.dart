import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/workout_session.dart';
import '../../services/workout_session_service.dart';

class WorkoutTimerScreen extends StatefulWidget {
  const WorkoutTimerScreen({super.key});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  final WorkoutSessionService _sessionService = WorkoutSessionService();
  Timer? _ticker;
  DateTime? _startedAt;
  bool _isSaving = false;

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
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
      if (!mounted) return;
      setState(() {});
    });
  }

  void _startWorkout() {
    if (_startedAt == null) {
      _startedAt = DateTime.now();
    }
    _stopwatch.start();
    _startTicker();
    setState(() {});
  }

  void _pauseWorkout() {
    _stopwatch.stop();
    setState(() {});
  }

  Future<void> _stopWorkout() async {
    if (_stopwatch.elapsed.inSeconds <= 0 || _startedAt == null) {
      return;
    }

    setState(() => _isSaving = true);

    final endedAt = DateTime.now();
    final session = WorkoutSession(
      id: endedAt.microsecondsSinceEpoch.toString(),
      startedAt: _startedAt!,
      endedAt: endedAt,
      durationSeconds: _stopwatch.elapsed.inSeconds,
    );

    await _sessionService.logSession(session);

    _ticker?.cancel();
    _stopwatch
      ..stop()
      ..reset();
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
    final canStop = _stopwatch.elapsed.inSeconds > 0;
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (_stopwatch.elapsed.inSeconds / 3600).clamp(0.0, 1.0);
    final elapsedMinutes = _stopwatch.elapsed.inMinutes;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Timer')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Card(
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
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              color: colorScheme.primary,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDuration(_stopwatch.elapsed),
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
                            icon: Icons.flag_outlined,
                            label: 'Target',
                            value: '60 min',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
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