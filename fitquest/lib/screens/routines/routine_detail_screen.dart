import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitquest/locale/app_localizations.dart';
import '../../services/api_service.dart';
import '../../providers/exercise_provider.dart';

class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({super.key});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  String? _routineId;
  List<Map<String, dynamic>> _exercises = [];
  bool _saving = false;
  bool _deleting = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final arg = ModalRoute.of(context)!.settings.arguments;
    Map<String, dynamic>? routine;

    if (arg is Map<String, dynamic>) {
      routine = arg;
    }

    if (routine == null) return;

    _routineId = (routine['_id'] ?? routine['id'])?.toString();
    _nameCtrl.text = routine['name']?.toString() ?? '';
    _descCtrl.text = routine['description']?.toString() ?? '';

    final rawExercises = routine['exercises'];
    if (rawExercises is List) {
      _exercises = rawExercises
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }

  void _openExercisePicker(int? index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final provider = Provider.of<ExerciseProvider>(ctx, listen: false);
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final all = provider.exercises;
            final loading = provider.isLoading;
            final filtered = query.isEmpty
                ? all
                : all
                      .where(
                        (e) =>
                            e.name.toLowerCase().contains(
                              query.toLowerCase(),
                            ) ||
                            e.category.toLowerCase().contains(
                              query.toLowerCase(),
                            ),
                      )
                      .toList();
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              builder: (_, sc) => Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search exercises...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (v) => setSheet(() => query = v),
                    ),
                  ),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : filtered.isEmpty
                        ? const Center(child: Text('No exercises found'))
                        : ListView.builder(
                            controller: sc,
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final ex = filtered[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(ex.name[0].toUpperCase()),
                                ),
                                title: Text(ex.name),
                                subtitle: Text(ex.category),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  setState(() {
                                    if (index == null) {
                                      _exercises.add({
                                        'name': ex.name,
                                        'reps': 0,
                                        'sets': 0,
                                        'durationSeconds': 0,
                                        'restSeconds': 0,
                                      });
                                    } else {
                                      _exercises[index]['name'] = ex.name;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_routineId == null) return;
    final loc = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    final res = await _api.updateRoutine(_routineId!, {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'exercises': _exercises,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (res['success'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Routine saved')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? loc.failedToSaveRoutine)),
      );
    }
  }

  Future<void> _delete() async {
    if (_routineId == null) return;
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
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(loc.removeLabel),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _deleting = true);
    final res = await _api.deleteRoutine(_routineId!);
    if (!mounted) return;
    setState(() => _deleting = false);
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
    final busy = _saving || _deleting;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.editRoutineTitle),
        actions: [
          if (_deleting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              tooltip: loc.removeLabel,
              onPressed: busy ? null : _delete,
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
            ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              tooltip: loc.saveRoutineLabel,
              onPressed: busy ? null : _save,
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: loc.nameLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? loc.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: loc.descriptionOptionalLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.exercises,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openExercisePicker(null),
                  icon: const Icon(Icons.add),
                  label: Text(loc.addLabel),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._exercises.asMap().entries.map((entry) {
              final idx = entry.key;
              final ex = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Tappable exercise name
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _openExercisePicker(idx),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: loc.exerciseNameLabel,
                            suffixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            ex['name']?.toString().isNotEmpty == true
                                ? ex['name'].toString()
                                : 'Tap to select...',
                            style: TextStyle(
                              fontSize: 16,
                              color: ex['name']?.toString().isNotEmpty == true
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: ex['reps']?.toString() ?? '0',
                              decoration: InputDecoration(
                                labelText: loc.repsLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  ex['reps'] = int.tryParse(v) ?? 0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: ex['sets']?.toString() ?? '0',
                              decoration: InputDecoration(
                                labelText: loc.setsLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  ex['sets'] = int.tryParse(v) ?? 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue:
                                  ex['durationSeconds']?.toString() ?? '0',
                              decoration: InputDecoration(
                                labelText: loc.durationSecLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  ex['durationSeconds'] = int.tryParse(v) ?? 0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue:
                                  ex['restSeconds']?.toString() ?? '0',
                              decoration: InputDecoration(
                                labelText: loc.restSecLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  ex['restSeconds'] = int.tryParse(v) ?? 0,
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () =>
                              setState(() => _exercises.removeAt(idx)),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            loc.removeLabel,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(loc.saveRoutineLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
