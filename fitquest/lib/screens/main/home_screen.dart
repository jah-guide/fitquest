import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitquest/locale/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'exercises_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.welcome}, ${user?['displayName'] ?? AppLocalizations.of(context)!.fitnessEnthusiast}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.readyWorkout,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Quick Stats
          Text(
            AppLocalizations.of(context)!.todaySummary,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.workouts,
                  '0',
                  Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.minutes,
                  '0',
                  Icons.timer,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Quick Actions
          Text(
            AppLocalizations.of(context)!.quickActions,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildActionCard(
                AppLocalizations.of(context)!.startWorkout,
                Icons.play_arrow,
                Colors.blue,
                onTap: () {
                  // For now, open Exercises as entrypoint to start a workout
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExercisesScreen()),
                  );
                },
              ),
              _buildActionCard(
                AppLocalizations.of(context)!.exercises,
                Icons.fitness_center,
                Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExercisesScreen()),
                  );
                },
              ),
              _buildActionCard(
                'Routines',
                Icons.repeat,
                Colors.teal,
                onTap: () {
                  Navigator.pushNamed(context, '/routines');
                },
              ),
              _buildActionCard(
                AppLocalizations.of(context)!.progress,
                Icons.trending_up,
                Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                  );
                },
              ),
              _buildActionCard(
                AppLocalizations.of(context)!.settings,
                Icons.settings,
                Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
