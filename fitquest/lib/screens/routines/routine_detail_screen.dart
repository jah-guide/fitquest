import 'package:flutter/material.dart';
import 'package:fitquest/locale/app_localizations.dart';
import '../../services/api_service.dart';

class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({super.key});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _routine;
  bool _loading = true;
  bool _loadedFromArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedFromArgs) return;
    _loadedFromArgs = true;

    final id = ModalRoute.of(context)!.settings.arguments;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }

    final routineId = id.toString();
    if (routineId.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    _loadRoutine(routineId);
  }

  Future<void> _loadRoutine(String id) async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      final res = await _api.getRoutine(id);
      if (!mounted) return;
      if (res['success'] == true && res['routine'] is Map) {
        setState(() => _routine = Map<String, dynamic>.from(res['routine']));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['error'] ?? loc.failedToLoadRoutine)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.failedToLoadRoutine)));
    }
    setState(() => _loading = false);
  }

  List<Map<String, dynamic>> _exercisesFromRoutine() {
    final exercises = _routine?['exercises'];
    if (exercises is! List) return const [];
    return exercises
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> _delete() async {
    if (_routine == null) return;
    final loc = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(loc.deleteRoutineQuestion),
        content: Text(loc.deleteRoutineConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(loc.removeLabel),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _loading = true);
    final res = await _api.deleteRoutine(_routine!['id'] ?? _routine!['_id']);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? loc.failedToDeleteRoutine)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_routine?['name'] ?? loc.routinesTitle),
        actions: [
          IconButton(
            onPressed: _delete,
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: colorScheme.primaryContainer,
                    ),
                    child: Text(
                      (_routine?['description'] ?? '').toString().isEmpty
                          ? loc.noDescriptionYet
                          : (_routine?['description'] ?? '').toString(),
                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.exercises,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: _exercisesFromRoutine().map((e) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.secondaryContainer,
                              child: Icon(
                                Icons.fitness_center,
                                color: colorScheme.secondary,
                              ),
                            ),
                            title: Text(e['name'] ?? ''),
                            subtitle: Text(
                              '${loc.repsLabel}: ${e['reps'] ?? 0} • ${loc.setsLabel}: ${e['sets'] ?? 0} • ${loc.durationLabel}: ${e['durationSeconds'] ?? 0}s',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
