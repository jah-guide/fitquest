// fitquest/lib/screens/exercises/offline_exercises_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exercise_provider.dart';
import '../../models/exercise.dart';
import '../../locale/app_localizations.dart';
import 'exercise_detail_screen.dart';
import '../../widgets/exercise_card.dart';

class OfflineExercisesScreen extends StatefulWidget {
  const OfflineExercisesScreen({super.key});

  @override
  State<OfflineExercisesScreen> createState() => _OfflineExercisesScreenState();
}

class _OfflineExercisesScreenState extends State<OfflineExercisesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExerciseProvider>(context, listen: false).loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final allCategories = exerciseProvider.exercises
        .map((e) => e.category)
        .toSet()
        .toList();
    allCategories.sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.exercises),
        actions: [
          // Sync button
          if (exerciseProvider.isOffline)
            IconButton(
              icon: Icon(Icons.sync_disabled, color: colorScheme.tertiary),
              onPressed: null,
              tooltip: 'Offline Mode',
            )
          else
            IconButton(
              icon: exerciseProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.sync),
              onPressed: exerciseProvider.syncNow,
              tooltip: 'Sync Now',
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colorScheme.primaryContainer,
            ),
            child: Row(
              children: [
                Icon(Icons.bolt, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exerciseProvider.isOffline
                        ? 'Offline mode: local edits will sync later.'
                        : 'Online mode: pull latest workouts and add your own.',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildFilterBar(allCategories, exerciseProvider),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => exerciseProvider.loadExercises(),
              child: _buildBody(exerciseProvider),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(context),
    );
  }

  String _selectedCategory = '';
  bool _showFavorites = false;
  String _searchQuery = '';

  Widget _buildFilterBar(List<String> categories, ExerciseProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search exercises',
                  ),
                  onChanged: (v) {
                    setState(() {
                      _searchQuery = v.trim().toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _showFavorites ? Icons.favorite : Icons.favorite_border,
                  color: _showFavorites ? colorScheme.error : null,
                ),
                onPressed: () =>
                    setState(() => _showFavorites = !_showFavorites),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Make the chips horizontally scrollable so many categories fit on small screens
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedCategory == '',
                    selectedColor: colorScheme.secondaryContainer,
                    onSelected: (_) => setState(() => _selectedCategory = ''),
                  ),
                ),
                for (final cat in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: _selectedCategory == cat,
                      selectedColor: colorScheme.secondaryContainer,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ExerciseProvider provider) {
    if (provider.isLoading && provider.exercises.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.exercises.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                Icons.fitness_center,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No exercises found',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            if (provider.isOffline)
              Text(
                'Working in offline mode',
                style: TextStyle(color: colorScheme.tertiary),
              ),
          ],
        ),
      );
    }

    // Apply filters
    var list = provider.exercises;
    if (_selectedCategory.isNotEmpty) {
      list = list
          .where(
            (e) => e.category.toLowerCase() == _selectedCategory.toLowerCase(),
          )
          .toList();
    }
    if (_showFavorites) {
      list = list.where((e) => provider.isFavorite(e)).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (e) =>
                e.name.toLowerCase().contains(_searchQuery) ||
                e.description.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length + 1,
      itemBuilder: (context, index) {
        if (index == list.length) {
          // Footer: Load more or indicator
          if (provider.isFetchingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.hasMoreRemote) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      provider.fetchRemoteExercises(loadMore: true),
                  icon: const Icon(Icons.expand_more),
                  label: const Text('Load more'),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        }

        final exercise = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ExerciseCard(
            exercise: exercise,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseDetailScreen(exercise: exercise),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddExerciseDialog(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );

    final nameController = TextEditingController();
    final descController = TextEditingController();
    final imageController = TextEditingController();
    String category = 'Chest';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: category,
              items: ['Chest', 'Back', 'Legs', 'Arms', 'Shoulders', 'Core']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                if (value != null) category = value;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newExercise = Exercise(
                name: nameController.text.trim().isEmpty
                    ? 'Untitled Exercise'
                    : nameController.text.trim(),
                category: category,
                description: descController.text.trim(),
                imageUrl: imageController.text.trim(),
                isSynced: false,
              );
              exerciseProvider.addExercise(newExercise);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
