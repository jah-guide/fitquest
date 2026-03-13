import 'package:flutter/material.dart';
import 'package:fitquest/locale/app_localizations.dart';
import '../../services/api_service.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _routines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadRoutines();
    });
  }

  Future<void> _loadRoutines() async {
    final loc = AppLocalizations.of(context);
    setState(() => _loading = true);
    try {
      final res = await _api.getRoutines();
      if (!mounted) return;
      if (res['success'] == true) {
        setState(() {
          _routines = _coerceListOfMaps(res['routines']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['error'] ??
                  loc?.failedToLoadRoutines ??
                  'Failed to load routines',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc?.failedToLoadRoutines ?? 'Failed to load routines'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Map<String, dynamic>> _coerceListOfMaps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.routinesTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRoutines,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: colorScheme.primaryContainer,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.routinesHeroText,
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.myRoutines,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () async {
                          Navigator.pushNamed(
                            context,
                            '/routines/create',
                          ).then((_) => _loadRoutines());
                        },
                        icon: const Icon(Icons.add),
                        label: Text(loc.newLabel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_routines.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        loc.noRoutinesYet,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ] else
                    ..._routines.map(_buildRoutineCard),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    loc.preloadedWorkouts,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _PreloadedWorkoutsSection(
                    onUseTemplate: (workout) {
                      Navigator.pushNamed(
                        context,
                        '/routines/create',
                        arguments: workout,
                      ).then((_) => _loadRoutines());
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRoutineCard(Map<String, dynamic> r) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(
          r['name'] ??
              r['title'] ??
              AppLocalizations.of(context)!.routinesTitle,
        ),
        subtitle: Text((r['description'] ?? '').toString()),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/routines/view',
            arguments: r,
          ).then((_) => _loadRoutines());
        },
      ),
    );
  }
}

class _PreloadedWorkoutsSection extends StatefulWidget {
  final void Function(dynamic workout) onUseTemplate;
  const _PreloadedWorkoutsSection({required this.onUseTemplate});

  @override
  State<_PreloadedWorkoutsSection> createState() =>
      _PreloadedWorkoutsSectionState();
}

class _PreloadedWorkoutsSectionState extends State<_PreloadedWorkoutsSection> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _workouts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getWorkouts();
      if (!mounted) return;
      if (res['success'] == true) {
        setState(() => _workouts = _coerceListOfMaps(res['workouts']));
      }
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Map<String, dynamic>> _coerceListOfMaps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_workouts.isEmpty) return Text(loc.noPreloadedWorkouts);
    return Column(
      children: _workouts.map((w) {
        return Card(
          child: ListTile(
            title: Text(w['title'] ?? 'Workout'),
            subtitle: Text((w['description'] ?? '').toString()),
            trailing: FilledButton.tonal(
              style: FilledButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
              onPressed: () => widget.onUseTemplate(w),
              child: Text(loc.useLabel),
            ),
          ),
        );
      }).toList(),
    );
  }
}
