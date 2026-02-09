
import 'package:flutter/material.dart';
import 'package:skillogic/pages/d_tribe/tribe_profile.dart';
import 'package:skillogic/pages/d_tribe/widgets/app_bar.dart';
import 'package:skillogic/pages/d_tribe/widgets/drawer_widget.dart';

class TribeHomeScreen extends StatefulWidget {
  const TribeHomeScreen({super.key});

  @override
  _TribeHomeScreenState createState() => _TribeHomeScreenState();
}

class _TribeHomeScreenState extends State<TribeHomeScreen> {
  int _currentIndex = 0;
  final List<String> _titles = ['Home', 'Chat', 'Search', 'Notifications', 'Your Profile'];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 4) {
      // Navigate to the profile screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TribeProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: _titles[_currentIndex]),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Featured',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Sample card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    child: Card(
                      color: Colors.black54,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar.jpg'), // Replace with actual image
                        ),
                        title: Text('Test', style: TextStyle(color: Colors.white)),
                        subtitle: Text('CDE doubt clearing session...', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: Colors.black54,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar.jpg'), // Replace with actual image
                        ),
                        title: Text('Test1', style: TextStyle(color: Colors.white)),
                        subtitle: Text('Link for doubt clearing session...', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1E2022),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Your Profile',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.black,
        backgroundColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}