
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillogic/pages/d_tribe/widgets/drawer_widget.dart';


class TribeProfileScreen extends StatefulWidget {
  const TribeProfileScreen({super.key});

  @override
  _TribeProfileScreenState createState() => _TribeProfileScreenState();
}

class _TribeProfileScreenState extends State<TribeProfileScreen> {
  String _username = '';
  String _profileUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('userName') ?? 'User Name';
      _profileUrl = prefs.getString('userImage') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2022),
        title: const Text('Your Profile'),
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.transparent,
              backgroundImage: _profileUrl.isNotEmpty
                  ? CachedNetworkImageProvider(_profileUrl)
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            title: Text(
              _username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('VIEW PROFILE'),
          ),
          const Divider(color: Colors.grey),
          _buildListTile('Personal Settings'),
          _buildListTile('Plans & Purchases'),
          _buildListTile('Saved Posts'),
          _buildListTile('Help Center'),
          const Divider(color: Colors.grey),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Activity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'You don’t have any activity yet',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildListTile(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        // Handle navigation to respective screens
      },
    );
  }
}
