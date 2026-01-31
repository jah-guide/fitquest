import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../locale/app_localizations.dart';
import '../../widgets/placeholder_image.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: exercise.imageUrl.isNotEmpty
                    ? Image.network(
                        exercise.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Image(
                          image: placeholderImageProvider(),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image(
                        image: placeholderImageProvider(),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(exercise.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Chip(label: Text(exercise.category)),
            const SizedBox(height: 16),
            Text(exercise.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  AppLocalizations.of(context)?.startWorkout ?? 'Start Workout',
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Starting ${exercise.name}...')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
