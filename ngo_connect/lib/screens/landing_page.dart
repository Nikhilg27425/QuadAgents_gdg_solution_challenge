import 'package:flutter/material.dart';
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
                              onPressed: () {},
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
                              onPressed: () {},
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
                          image: NetworkImage('https://images.unsplash.com/photo-1593113563332-afceed8f14af?auto=format&fit=crop&w=800&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats Bar
            Container(
              width: double.infinity,
              color: AppTheme.primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('12k+', 'NEEDS FULFILLED'),
                  _buildStatItem('45k+', 'ACTIVE VOLUNTEERS'),
                  _buildStatItem('850+', 'REGISTERED NGOS'),
                  _buildStatItem('24/7', 'SUPPORT HOURS'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 1.2)),
      ],
    );
  }
}
