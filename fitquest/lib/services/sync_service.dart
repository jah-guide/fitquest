// fitquest/lib/services/sync_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import './database_helper.dart';
import '../models/exercise.dart';
import 'api_service.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Connectivity _connectivity = Connectivity();
  final ApiService _apiService = ApiService();

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> syncExercises() async {
    final isConnected = await checkConnectivity();
    if (!isConnected) return;

    // 1. Get unsynced exercises from local DB
    final unsyncedExercises = await _dbHelper.getUnsyncedExercises();

    // 2. Push each unsynced exercise to the authenticated backend API
    for (final exercise in unsyncedExercises) {
      try {
        await _syncExerciseToServer(exercise);

        // Mark as synced in local DB
        await _dbHelper.updateExercise(exercise.copyWith(isSynced: true));
      } catch (e) {
        debugPrint('Failed to sync exercise ${exercise.name}: $e');
      }
    }

    // 3. Fetch latest exercises from server
    await _fetchLatestExercises();
  }

  Future<void> _syncExerciseToServer(Exercise exercise) async {
    final result = await _apiService.createExercise(
      name: exercise.name,
      category: exercise.category,
      description: exercise.description,
      imageUrl: exercise.imageUrl,
    );

    if (result['success'] != true) {
      throw Exception(result['error'] ?? 'Failed to sync exercise');
    }
  }

  Future<void> _fetchLatestExercises() async {
    try {
      final result = await _apiService.getExercises();
      if (result['success'] != true) return;

      final remoteRaw = (result['exercises'] as List<dynamic>? ?? const []);
      final local = await _dbHelper.getAllExercises();
      final known = local
          .map((e) => '${e.name.toLowerCase()}|${e.category.toLowerCase()}')
          .toSet();

      for (final item in remoteRaw) {
        if (item is! Map<String, dynamic>) continue;
        final exercise = Exercise(
          name: (item['name'] ?? '').toString(),
          category: (item['category'] ?? 'General').toString(),
          description: (item['description'] ?? '').toString(),
          imageUrl: (item['imageUrl'] ?? '').toString(),
          isSynced: true,
          createdAt: item['createdAt'] is String
              ? DateTime.tryParse(item['createdAt']) ?? DateTime.now()
              : DateTime.now(),
        );

        final key = '${exercise.name.toLowerCase()}|${exercise.category.toLowerCase()}';
        if (known.contains(key)) continue;

        try {
          await _dbHelper.insertExercise(exercise);
          known.add(key);
        } catch (_) {
          // Ignore local persistence failures on unsupported platforms.
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch exercises: $e');
    }
  }

  Future<void> addExerciseOffline(Exercise exercise) async {
    // Save locally with isSynced = false
    final offlineExercise = exercise.copyWith(isSynced: false);
    await _dbHelper.insertExercise(offlineExercise);

    // Try to sync immediately
    await syncExercises();
  }
}

// Extension for copying exercises
extension ExerciseCopyWith on Exercise {
  Exercise copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    String? imageUrl,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
