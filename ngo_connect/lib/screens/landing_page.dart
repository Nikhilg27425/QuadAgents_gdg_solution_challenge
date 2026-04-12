import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import 'login_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.show_chart, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'NGO Connect',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text('Login', style: TextStyle(color: AppTheme.textDark)),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text('Join Now'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 64.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'New: AI-Powered Skill Matching',
                            style: TextStyle(color: AppTheme.primaryPurple, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 24),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.displayLarge,
                            children: const [
                              TextSpan(text: 'Connect Your '),
                              TextSpan(text: 'Skills\n', style: TextStyle(color: AppTheme.primaryPurple)),
                              TextSpan(text: 'With Social '),
                              TextSpan(text: 'Impact', style: TextStyle(color: Color(0xFF00B4D8))), // Teal contrast
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'NGO Connect is the unified bridge between world-changing organizations and passionate volunteers. Transform your spare time into real-world change.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => const LoginScreen()
                                ));
                              },
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
                              child: const Row(
                                children: [
                                  Text('Join as Volunteer'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => const LoginScreen()
                                ));
                              },
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
                              child: const Text('Register NGO'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 64),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=800&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats Bar — live counts from Firestore (Requirements 1.3, 12.5)
            const _LiveStatsBar(),
          ],
        ),
      ),
    );
  }

}

/// Fetches live counts from Firestore and displays them in the stats bar.
/// Requirements 1.3, 12.5: no hardcoded placeholder values.
class _LiveStatsBar extends StatelessWidget {
  const _LiveStatsBar();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _fetchStats(),
      builder: (context, snap) {
        final stats = snap.data;
        return Container(
          width: double.infinity,
          color: AppTheme.primaryPurple,
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(
                stats != null ? '${stats['fulfilled']}+' : '—',
                'NEEDS FULFILLED',
              ),
              _statItem(
                stats != null ? '${stats['volunteers']}+' : '—',
                'ACTIVE VOLUNTEERS',
              ),
              _statItem(
                stats != null ? '${stats['ngos']}+' : '—',
                'REGISTERED NGOS',
              ),
              _statItem(
                stats != null ? '${stats['tasks']}+' : '—',
                'TASKS COMPLETED',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, int>> _fetchStats() async {
    final db = FirebaseFirestore.instance;
    final results = await Future.wait([
      db.collection('needs').where('status', isEqualTo: 'closed').count().get(),
      db.collection('users').where('role', isEqualTo: 'volunteer').count().get(),
      db.collection('ngos').count().get(),
      db.collection('task_assignments').where('status', isEqualTo: 'closed').count().get(),
    ]);
    return {
      'fulfilled': results[0].count ?? 0,
      'volunteers': results[1].count ?? 0,
      'ngos': results[2].count ?? 0,
      'tasks': results[3].count ?? 0,
    };
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1.2)),
      ],
    );
  }
}
