import 'package:flutter/material.dart';
import '../models/exercise.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import 'placeholder_image.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;

  const ExerciseCard({super.key, required this.exercise, this.onTap});

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<ExerciseProvider>(context);
    final isFav = favProvider.isFavorite(exercise);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area (use Image.network with errorBuilder for web/CORS)
            SizedBox(
              height: 140,
              width: double.infinity,
              child: exercise.imageUrl.isNotEmpty
                  ? Image.network(
                      exercise.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Image(
                        image: placeholderImageProvider(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Image(
                      image: placeholderImageProvider(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),

            // Info area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          exercise.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(label: Text(exercise.category)),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action column (fixed width)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => favProvider.toggleFavorite(exercise),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: onTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
