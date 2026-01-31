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
    final allCategories = exerciseProvider.exercises
        .map((e) => e.category)
        .toSet()
        .toList();
    allCategories.sort();

    // Filter state
    String selectedCategory = _selectedCategory;
    final showFavorites = _showFavorites;
    final query = _searchQuery;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.exercises),
        actions: [
          // Sync button
          if (exerciseProvider.isOffline)
            IconButton(
              icon: const Icon(Icons.sync_disabled, color: Colors.orange),
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
                  color: _showFavorites ? Colors.red : null,
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
                    onSelected: (_) => setState(() => _selectedCategory = ''),
                  ),
                ),
                for (final cat in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: _selectedCategory == cat,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'No exercises found',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (provider.isOffline)
              Text(
                'Working in offline mode',
                style: TextStyle(color: Colors.orange[700]),
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
                child: ElevatedButton(
                  onPressed: () =>
                      provider.fetchRemoteExercises(loadMore: true),
                  child: const Text('Load more'),
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

  Widget _buildExerciseCard(Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(_getCategoryIcon(exercise.category), color: Colors.blue),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.category),
            const SizedBox(height: 4),
            Text(
              exercise.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!exercise.isSynced)
              const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right),
          ],
        ),
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
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return Icons.fitness_center;
      case 'back':
        return Icons.arrow_upward;
      case 'legs':
        return Icons.directions_walk;
      case 'arms':
        return Icons.accessibility;
      case 'shoulders':
        return Icons.zoom_out_map;
      case 'core':
        return Icons.center_focus_strong;
      default:
        return Icons.fitness_center;
    }
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
              value: category,
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
