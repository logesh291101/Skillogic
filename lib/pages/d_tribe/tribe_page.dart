
import 'package:flutter/material.dart';
import 'package:skillogic/pages/d_tribe/welcome_screen.dart';

class TribePage extends StatelessWidget {
  const TribePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2022), // Dark background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'D-Tribe',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                'Be a part of\nsomething',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const Text(
                'Tribe',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF6FD4D4), // Light blue color
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://img.freepik.com/free-photo/view-diverse-adolescents-practicing-health-wellness-activities-themselves-their-community_23-2151416262.jpg?t=st=1722336309~exp=1722339909~hmac=6fb5eb6521f63151d902c868dc58a6fe1ffa7f2e0fc7ce2afaa969079c089ac9&w=996', // Replace with the actual image URL
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 20,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle Sign In tap
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E8181), // Light blue background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        "https://img.freepik.com/free-photo/group-young-friends-gathering-together_23-2148431361.jpg?w=900&t=st=1722337764~exp=1722338364~hmac=b3521daaa68c96fccc17d1be4e0422d78c7030a100ded76b0c3f7d75f042b87f",
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 20,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                        );
                        // Handle Discover Networks tap
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6CAB8), // Beige background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Discover Networks',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Center(
                child: Text(
                  'or, Create a new Network',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}