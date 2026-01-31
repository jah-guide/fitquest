// fitquest/lib/providers/exercise_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
// API removed for exercises — use sample data only
// import '../services/exercise_api_service.dart';
import '../services/sample_data.dart';
import '../models/exercise.dart';
import '../services/sample_data.dart';

class ExerciseProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SyncService _syncService = SyncService();
  // final ExerciseApiService _apiService = ExerciseApiService();

  List<Exercise> _exercises = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String? _nextRemoteUrl;
  bool _isFetchingMore = false;
  // favorites stored as string keys (id or name fallback)
  final Set<String> _favorites = {};

  static const _favoritesKey = 'favorite_exercises';

  List<Exercise> get exercises => _exercises;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMoreRemote => _nextRemoteUrl != null;
  Set<String> get favorites => _favorites;

  ExerciseProvider() {
    _loadFavorites();
  }

  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load from local DB
      try {
        _exercises = await _dbHelper.getAllExercises();
      } catch (e) {
        _exercises = [];
      }

      // If no local exercises, use bundled sample data and persist when possible
      if (_exercises.isEmpty) {
        // Use in-memory sample list
        _exercises = SampleData.sampleExercises;
        // Try to persist to DB when supported
        try {
          for (final ex in _exercises) {
            await _dbHelper.insertExercise(ex);
          }
        } catch (_) {
          // ignore persistence errors (e.g., web)
        }
      }
    } catch (e) {
      // Provide a lightweight in-memory fallback for platforms where
      // path_provider / sqflite are not available (e.g., web in this setup).
      print('Error loading exercises: $e');
      if (kIsWeb || e.toString().contains('MissingPluginException')) {
        _isOffline = true;
        _exercises = [
          Exercise(
            name: 'Push-ups',
            category: 'Chest',
            description: 'Classic chest exercise',
            imageUrl: '',
          ),
          Exercise(
            name: 'Squats',
            category: 'Legs',
            description: 'Leg and glute exercise',
            imageUrl: '',
          ),
          Exercise(
            name: 'Plank',
            category: 'Core',
            description: 'Core stability exercise',
            imageUrl: '',
          ),
        ];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch exercises from remote API and cache into local DB when possible.
  Future<void> fetchRemoteExercises({
    int limit = 30,
    bool loadMore = false,
  }) async {
    // API fetching for exercises has been removed — sample data only.
    // This method is kept as a no-op for compatibility.
    return;
  }

  // Favorites persistence
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_favoritesKey) ?? [];
      _favorites.clear();
      _favorites.addAll(list);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favorites.toList());
    } catch (_) {}
  }

  String _keyForExercise(Exercise e) => e.id != null ? e.id.toString() : e.name;

  bool isFavorite(Exercise e) => _favorites.contains(_keyForExercise(e));

  Future<void> toggleFavorite(Exercise e) async {
    final key = _keyForExercise(e);
    if (_favorites.contains(key))
      _favorites.remove(key);
    else
      _favorites.add(key);
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> addExercise(Exercise exercise) async {
    try {
      await _syncService.addExerciseOffline(exercise);
      await loadExercises(); // Reload list
    } catch (e) {
      // Fallback for web / missing plugins: add locally
      print('Error adding exercise: $e');
      _exercises.add(exercise);
      notifyListeners();
    }
  }

  Future<void> syncNow() async {
    _isLoading = true;
    notifyListeners();

    await _syncService.syncExercises();
    await loadExercises();

    _isLoading = false;
    notifyListeners();
  }
}
