import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

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
                    'Welcome, ${user?['displayName'] ?? 'Fitness Enthusiast'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ready for your next workout?',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Quick Stats
          const Text(
            'Today\'s Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildStatCard('Workouts', '0', Icons.fitness_center),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard('Minutes', '0', Icons.timer),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildActionCard('Start Workout', Icons.play_arrow, Colors.blue),
              _buildActionCard('Exercises', Icons.fitness_center, Colors.green),
              _buildActionCard('Progress', Icons.trending_up, Colors.orange),
              _buildActionCard('Settings', Icons.settings, Colors.purple),
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Implement action
        },
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}