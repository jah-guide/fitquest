import 'package:flutter/material.dart';
import '../exercises/offline_exercises_screen.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OfflineExercisesScreen(); // Now uses offline version
  }
}
