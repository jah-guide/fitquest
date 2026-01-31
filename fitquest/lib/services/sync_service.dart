// fitquest/lib/services/sync_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import './database_helper.dart';
import '../models/exercise.dart';
import 'exercise_api_service.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Connectivity _connectivity = Connectivity();
  final ExerciseApiService _apiService = ExerciseApiService();

  // Simulate API endpoints
  static const String baseUrl = 'http://your-api.com/api';

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> syncExercises() async {
    final isConnected = await checkConnectivity();
    if (!isConnected) return;

    // 1. Get unsynced exercises from local DB
    final unsyncedExercises = await _dbHelper.getUnsyncedExercises();

    // 2. Sync each unsynced exercise
    for (final exercise in unsyncedExercises) {
      try {
        // Simulate API call to sync exercise
        await _syncExerciseToServer(exercise);

        // Mark as synced in local DB
        await _dbHelper.updateExercise(exercise.copyWith(isSynced: true));
      } catch (e) {
        print('Failed to sync exercise ${exercise.name}: $e');
      }
    }

    // 3. Fetch latest exercises from server
    await _fetchLatestExercises();
  }

  Future<void> _syncExerciseToServer(Exercise exercise) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    print('Synced exercise to server: ${exercise.name}');
  }

  Future<void> _fetchLatestExercises() async {
    try {
      // Use the ExerciseApiService (wger) to fetch recent exercises instead
      final res = await _apiService.fetchExercises(limit: 30);
      final remote = (res['results'] as List<dynamic>).cast<Exercise>();
      for (final exercise in remote) {
        try {
          await _dbHelper.insertExercise(exercise);
        } catch (e) {
          // ignore DB insert errors on unsupported platforms
        }
      }
    } catch (e) {
      print('Failed to fetch exercises: $e');
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
