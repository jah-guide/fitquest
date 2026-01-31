import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:fitquest/locale/app_localizations.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  String _name = '';
  String _description = '';
  List<Map<String, dynamic>> _exercises = [];
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg != null && arg is Map<String, dynamic>) {
      // Pre-fill from workout template
      setState(() {
        _name = arg['title'] ?? '';
        _description = arg['description'] ?? '';
        _exercises =
            (arg['exercises'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];
      });
    }
  }

  void _addExercise() {
    setState(() {
      _exercises.add({
        'name': '',
        'reps': 0,
        'sets': 0,
        'durationSeconds': 0,
        'restSeconds': 0,
      });
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    final payload = {
      'name': _name,
      'description': _description,
      'exercises': _exercises,
    };
    final res = await _api.createRoutine(payload);
    setState(() => _loading = false);
    if (res['success'] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['error'] ?? 'Failed to save')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Routine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                onSaved: (v) => _name = v ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                onSaved: (v) => _description = v ?? '',
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Exercises',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._exercises.asMap().entries.map((entry) {
                final idx = entry.key;
                final ex = entry.value;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: ex['name'],
                          decoration: const InputDecoration(
                            labelText: 'Exercise name',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                          onChanged: (v) => ex['name'] = v,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: ex['reps']?.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Reps',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) =>
                                    ex['reps'] = int.tryParse(v) ?? 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: ex['sets']?.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Sets',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) =>
                                    ex['sets'] = int.tryParse(v) ?? 0,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: ex['durationSeconds']?.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Duration (sec)',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => ex['durationSeconds'] =
                                    int.tryParse(v) ?? 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: ex['restSeconds']?.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Rest (sec)',
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
                            onPressed: () {
                              setState(() {
                                _exercises.removeAt(idx);
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Remove',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Save Routine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
