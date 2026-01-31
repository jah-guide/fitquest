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
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.workouts)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRoutines,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Routines',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ElevatedButton.icon(
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
                    Center(child: Text('No routines yet. Create one!')),
                  ] else
                    ..._routines.map((r) => _buildRoutineCard(r)).toList(),
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
        title: Text(r['name'] ?? r['title'] ?? 'Routine'),
        subtitle: Text((r['description'] ?? '').toString()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/routines/view',
            arguments: r['id'] ?? r['_id'],
          )?.then((_) => _loadRoutines());
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
    if (res['success'] == true) {
      setState(() => _workouts = res['workouts']);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_workouts.isEmpty) return const Text('No preloaded workouts');
    return Column(
      children: _workouts.map((w) {
        return Card(
          child: ListTile(
            title: Text(w['title'] ?? 'Workout'),
            subtitle: Text((w['description'] ?? '').toString()),
            trailing: ElevatedButton(
              onPressed: () => widget.onUseTemplate(w),
              child: const Text('Use'),
            ),
          ),
        );
      }).toList(),
    );
  }
}
