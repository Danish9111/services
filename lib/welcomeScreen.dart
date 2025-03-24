import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/labour_services_logo.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 30),
            const Text(
              "Welcome to Labour Services",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you new here ? ',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/getStarted');
              },
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 50),
            const Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 2,
                    indent: 40,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or'),
                ),
                Expanded(
                  child: Divider(
                    thickness: 2,
                    endIndent: 40,
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'Already have an account?',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 12),
                side: const BorderSide(color: Colors.orangeAccent, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/signIn'); // Navigate to '/signIn'
              },
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 18, color: Colors.orangeAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
