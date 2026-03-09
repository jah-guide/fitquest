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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          exercise.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Chip(
                          label: Text(exercise.category),
                          backgroundColor: colorScheme.secondaryContainer,
                          side: BorderSide.none,
                          labelStyle: TextStyle(color: colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => favProvider.toggleFavorite(exercise),
                        tooltip: 'Favorite',
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
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
