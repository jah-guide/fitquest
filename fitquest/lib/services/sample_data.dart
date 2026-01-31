// fitquest/lib/services/sample_data.dart
import './database_helper.dart';
import '../models/exercise.dart';

class SampleData {
  static List<Exercise> get sampleExercises {
    // Raw tuples: [name, category, description]
    final raw = [
      [
        'Push-ups',
        'Chest',
        'A bodyweight pushing exercise that works the chest, shoulders and triceps.',
      ],
      [
        'Wide Push-ups',
        'Chest',
        'Variation that emphasizes the outer chest and shoulders.',
      ],
      [
        'Incline Push-ups',
        'Chest',
        'Push-ups with hands elevated to focus on upper chest.',
      ],
      [
        'Decline Push-ups',
        'Chest',
        'Feet elevated variation to emphasize upper chest.',
      ],
      [
        'Bench Press',
        'Chest',
        'Barbell pressing movement for overall chest strength.',
      ],
      [
        'Dumbbell Bench Press',
        'Chest',
        'Unilateral pressing to improve balance and stabilization.',
      ],
      [
        'Chest Fly',
        'Chest',
        'Isolation movement targeting the pectoral muscles.',
      ],
      [
        'Pull-ups',
        'Back',
        'Vertical pulling to strengthen lats, biceps and upper back.',
      ],
      [
        'Chin-ups',
        'Back',
        'Pull-up variant with underhand grip to emphasize biceps.',
      ],
      [
        'Lat Pulldown',
        'Back',
        'Machine exercise to work the latissimus dorsi.',
      ],
      [
        'Bent Over Row',
        'Back',
        'Compound row movement for mid-back thickness.',
      ],
      [
        'Single-arm Dumbbell Row',
        'Back',
        'Unilateral row for balance and scapular control.',
      ],
      [
        'Deadlift',
        'Back',
        'Full-body posterior chain lift for strength and power.',
      ],
      ['Romanian Deadlift', 'Legs', 'Hamstring-focused deadlift variation.'],
      [
        'Squats',
        'Legs',
        'Primary lower-body movement for quads, glutes and core.',
      ],
      [
        'Front Squat',
        'Legs',
        'Targets quads and core with more upright torso.',
      ],
      [
        'Lunges',
        'Legs',
        'Unilateral leg movement for balance, quads and glutes.',
      ],
      [
        'Step-ups',
        'Legs',
        'Functional single-leg movement using a bench or box.',
      ],
      ['Leg Press', 'Legs', 'Machine-based compound for quad development.'],
      ['Calf Raises', 'Legs', 'Isolation exercise for calf muscles.'],
      [
        'Bicep Curls',
        'Arms',
        'Isolation movement targeting the biceps brachii.',
      ],
      ['Hammer Curls', 'Arms', 'Targets brachialis and forearm muscles.'],
      [
        'Tricep Dips',
        'Arms',
        'Bodyweight triceps exercise (bench or parallel bars).',
      ],
      [
        'Tricep Pushdown',
        'Arms',
        'Cable isolation for triceps strength and definition.',
      ],
      [
        'Overhead Tricep Extension',
        'Arms',
        'Single-arm or two-hand extension for long head of triceps.',
      ],
      [
        'Shoulder Press',
        'Shoulders',
        'Overhead pressing for deltoid strength.',
      ],
      ['Lateral Raises', 'Shoulders', 'Isolation movement for medial deltoid.'],
      [
        'Front Raises',
        'Shoulders',
        'Anterior deltoid isolation with dumbbells or plate.',
      ],
      [
        'Rear Delt Fly',
        'Shoulders',
        'Targets posterior deltoids and upper back.',
      ],
      [
        'Arnold Press',
        'Shoulders',
        'Rotational press for full deltoid development.',
      ],
      [
        'Plank',
        'Core',
        'Isometric core stability exercise for deep trunk muscles.',
      ],
      ['Side Plank', 'Core', 'Lateral core strength and oblique emphasis.'],
      [
        'Hanging Leg Raise',
        'Core',
        'Advanced core exercise focusing on lower abs.',
      ],
      ['Russian Twist', 'Core', 'Rotational core exercise for obliques.'],
      [
        'Mountain Climbers',
        'Core',
        'Dynamic core and cardio combination movement.',
      ],
      [
        'Burpees',
        'Full Body',
        'High-intensity full-body conditioning movement.',
      ],
      [
        'Kettlebell Swing',
        'Full Body',
        'Hip-hinge power movement for posterior chain.',
      ],
      [
        'Jump Rope',
        'Cardio',
        'Simple cardio tool for coordination and stamina.',
      ],
      ['Box Jumps', 'Cardio', 'Plyometric lower-body power exercise.'],
      [
        'Farmer\'s Walk',
        'Full Body',
        'Grip and core strength with loaded carry.',
      ],
      [
        'Glute Bridge',
        'Legs',
        'Hip thrust alternative to build glutes and hamstrings.',
      ],
      [
        'Hip Thrust',
        'Legs',
        'Primary glute-building exercise using barbell or bench.',
      ],
      [
        'Bird Dog',
        'Core',
        'Low-load core stability and lumbar control exercise.',
      ],
      [
        'Good Mornings',
        'Back',
        'Hamstring and lower-back strengthening hip hinge.',
      ],
      [
        'Cable Woodchop',
        'Core',
        'Anti-rotational and oblique strengthening movement.',
      ],
      [
        'Incline Dumbbell Press',
        'Chest',
        'Upper chest emphasis with dumbbells.',
      ],
      [
        'Decline Bench Press',
        'Chest',
        'Lower chest emphasis using decline bench.',
      ],
      ['Face Pulls', 'Back', 'Rear delt and scapular health exercise.'],
      [
        'Single-leg Romanian Deadlift',
        'Legs',
        'Balance and hamstring strength with single leg focus.',
      ],
    ];

    String _expandDescription(String base, String category) {
      final cat = category.toLowerCase();
      return '$base It targets the $cat and helps improve strength, stability, and mobility when performed correctly. Focus on controlled repetitions and proper technique, breathing steadily and maintaining good posture. Progress gradually by adding resistance or volume to continue making gains while minimising injury risk.';
    }

    final list = <Exercise>[];
    int seed = 1;
    for (final row in raw) {
      final name = row[0] as String;
      final category = row[1] as String;
      final baseDesc = row[2] as String;
      final description = _expandDescription(baseDesc, category);
      final imageUrl =
          'https://picsum.photos/seed/${Uri.encodeComponent(name)}/600/400';
      final safeImage = 'https://picsum.photos/seed/sample$seed/600/400';
      seed++;
      list.add(
        Exercise(
          name: name,
          category: category,
          description: description,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : safeImage,
          isSynced: true,
        ),
      );
    }

    return list;
  }

  static Future<void> initializeSampleExercises() async {
    final dbHelper = DatabaseHelper();

    final existing = await dbHelper.getAllExercises();
    if (existing.isNotEmpty) return; // already seeded

    for (final ex in sampleExercises) {
      await dbHelper.insertExercise(ex);
    }
  }
}
