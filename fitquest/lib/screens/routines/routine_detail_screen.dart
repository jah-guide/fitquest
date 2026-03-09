import 'package:flutter/material.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments;
    if (id != null && id is String) _loadRoutine(id);
  }

  Future<void> _loadRoutine(String id) async {
    setState(() => _loading = true);
    final res = await _api.getRoutine(id);
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() => _routine = res['routine']);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['error'] ?? 'Failed to load')));
    }
    setState(() => _loading = false);
  }

  Future<void> _delete() async {
    if (_routine == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete routine?'),
        content: const Text('This will permanently delete the routine.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
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
        SnackBar(content: Text(res['error'] ?? 'Failed to delete')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_routine?['name'] ?? 'Routine'),
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
                          ? 'No description added yet.'
                          : (_routine?['description'] ?? '').toString(),
                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Exercises',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: (_routine?['exercises'] as List<dynamic>? ?? [])
                          .map((e) {
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      colorScheme.secondaryContainer,
                                  child: Icon(
                                    Icons.fitness_center,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                                title: Text(e['name'] ?? ''),
                                subtitle: Text(
                                  'Reps: ${e['reps'] ?? 0} • Sets: ${e['sets'] ?? 0} • Duration: ${e['durationSeconds'] ?? 0}s',
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
