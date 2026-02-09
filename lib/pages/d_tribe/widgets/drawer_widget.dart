import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 100, // Set the desired height here
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.swap_horiz, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Switch Networks', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage('https://media1-production-mightynetworks.imgix.net/asset/17237639/blue__1_.jpg?ixlib=rails-4.2.0&fm=jpg&q=100&auto=format&w=98&h=98&fit=crop&crop=faces&impolicy=Avatar'),
              ),
              title: Text('D-Tribe', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.feed, color: Colors.white),
              title: const Text('Feed', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.explore, color: Colors.white),
              title: const Text('Discovery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.white),
              title: const Text('Members', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.grey),
            const ListTile(
              title: Text('General', style: TextStyle(color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              title: const Text('See Network Details', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Personal Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}