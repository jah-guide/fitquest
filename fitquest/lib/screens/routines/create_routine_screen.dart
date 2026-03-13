import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitquest/locale/app_localizations.dart';
import '../../services/api_service.dart';
import '../../providers/exercise_provider.dart';
import '../../models/exercise.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  List<Map<String, dynamic>> _exercises = [];
  bool _loading = false;
  bool _initializedFromArgs = false;
  String? _editingId; // non-null when editing an existing routine

  bool get _isEditing => _editingId != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedFromArgs) return;
    _initializedFromArgs = true;

    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg != null && arg is Map<String, dynamic>) {
      final id = (arg['_id'] ?? arg['id'])?.toString();
      final isExistingRoutine = id != null && id.isNotEmpty;

      if (isExistingRoutine) {
        _editingId = id;
        _nameCtrl.text =
            arg['name']?.toString() ?? arg['title']?.toString() ?? '';
        _descCtrl.text = arg['description']?.toString() ?? '';
      } else {
        _nameCtrl.text = arg['title']?.toString() ?? '';
        _descCtrl.text = arg['description']?.toString() ?? '';
      }
      setState(() {
        _exercises =
            (arg['exercises'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];
      });
    }
  }

  void _addExercise() {
    _openExercisePicker(null);
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
          builder: (ctx, setSheetState) {
            final allExercises = provider.exercises;
            final isLoading = provider.isLoading;
            final filtered = query.isEmpty
                ? allExercises
                : allExercises
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
              builder: (_, scrollController) => Column(
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
                      onChanged: (v) => setSheetState(() => query = v),
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filtered.isEmpty
                        ? const Center(child: Text('No exercises found'))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final ex = filtered[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    ex.name[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
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
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final payload = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'exercises': _exercises,
    };
    final res = _isEditing
        ? await _api.updateRoutine(_editingId!, payload)
        : await _api.createRoutine(payload);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? loc.failedToSaveRoutine)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? loc.editRoutineTitle : loc.createRoutineTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colorScheme.secondaryContainer,
                ),
                child: Row(
                  children: [
                    Icon(Icons.construction, color: colorScheme.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.createRoutineHeroText,
                        style: TextStyle(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.exercises,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addExercise,
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
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        FormField<String>(
                          initialValue: ex['name'] as String?,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? loc.required : null,
                          builder: (field) => InputDecorator(
                            decoration: InputDecoration(
                              labelText: loc.exerciseNameLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: const Icon(Icons.search),
                              errorText: field.errorText,
                            ),
                            child: InkWell(
                              onTap: () => _openExercisePicker(idx),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  ex['name']?.toString().isNotEmpty == true
                                      ? ex['name'].toString()
                                      : 'Tap to select exercise...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        ex['name']?.toString().isNotEmpty ==
                                            true
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: ex['reps']?.toString(),
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
                                initialValue: ex['sets']?.toString(),
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: ex['durationSeconds']?.toString(),
                                decoration: InputDecoration(
                                  labelText: loc.durationSecLabel,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
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
                            onPressed: () {
                              setState(() {
                                _exercises.removeAt(idx);
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: Text(
                              loc.removeLabel,
                              style: TextStyle(color: Colors.red),
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
                  onPressed: _loading ? null : _save,
                  icon: Icon(_isEditing ? Icons.check : Icons.save),
                  label: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEditing
                              ? loc.saveRoutineLabel
                              : loc.saveRoutineLabel,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
