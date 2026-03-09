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
  List<dynamic> _routines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    setState(() => _loading = true);
    final res = await _api.getRoutines();
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() {
        _routines = res['routines'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'Failed to load routines')),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.workouts)),
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
                            'Build, save, and reuse routines like a pro coach.',
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
                        'My Routines',
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
                        label: const Text('New'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_routines.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        'No routines yet. Create one!',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ] else
                    ..._routines.map((r) => _buildRoutineCard(r)),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    'Preloaded Workouts',
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

  Widget _buildRoutineCard(dynamic r) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(r['name'] ?? r['title'] ?? 'Routine'),
        subtitle: Text((r['description'] ?? '').toString()),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/routines/view',
            arguments: r['id'] ?? r['_id'],
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
  List<dynamic> _workouts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _loading = true);
    final res = await _api.getWorkouts();
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() => _workouts = res['workouts']);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_workouts.isEmpty) return const Text('No preloaded workouts');
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
              child: const Text('Use'),
            ),
          ),
        );
      }).toList(),
    );
  }
}
