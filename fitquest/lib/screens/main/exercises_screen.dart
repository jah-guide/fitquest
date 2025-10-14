import 'package:flutter/material.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exercises',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Exercise Categories
              _buildExerciseCategory('Chest', Icons.fitness_center, Colors.blue),
              _buildExerciseCategory('Back', Icons.arrow_upward, Colors.green),
              _buildExerciseCategory('Legs', Icons.directions_walk, Colors.orange),
              _buildExerciseCategory('Arms', Icons.accessibility, Colors.red),
              _buildExerciseCategory('Shoulders', Icons.zoom_out_map, Colors.purple),
              _buildExerciseCategory('Core', Icons.center_focus_strong, Colors.teal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCategory(String name, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('View exercises and workouts'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to specific exercise category
          print('$name category tapped');
        },
      ),
    );
  }
}