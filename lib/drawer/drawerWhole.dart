import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Drawer buildNavigationDrawer(context) {
  return Drawer(
    child: Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerSectionHeader('Main Menu'),
          _buildDrawerItem(Icons.home, 'Home', () {}),
          _buildDrawerItem(Icons.explore, 'Browse Services', () {}),
          _buildDrawerItem(Icons.history, 'Service History', () {}),
          const Divider(
            height: 1,
          ),
          _buildDrawerSectionHeader('Account'),
          _buildDrawerItem(Icons.person, 'My Profile', () {}),
          _buildDrawerItem(Icons.payment, 'Payment Methods', () {}),
          _buildDrawerItem(Icons.settings, 'App Settings', () {}),
          const Divider(height: 1),
          _buildDrawerSectionHeader('Support'),
          _buildDrawerItem(Icons.help, 'Help Center', () {}),
          _buildDrawerItem(Icons.phone, 'Contact Us', () {}),
          const SizedBox(height: 20),
          _buildDrawerFooter(context),
        ],
      ),
    ),
  );
}

UserAccountsDrawerHeader _buildDrawerHeader() {
  return UserAccountsDrawerHeader(
    decoration: BoxDecoration(color: Colors.blueGrey.shade800),
    accountName: const Text(
      "Nadeem Danish",
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
    accountEmail: const Text(
      "nadeem@example.com",
      style: TextStyle(color: Colors.white),
    ),
    currentAccountPicture: CircleAvatar(
      backgroundColor: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset('assets/profile_pic.jpeg', fit: BoxFit.cover),
      ),
    ),
  );
}

Widget _buildDrawerSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(
      title,
      style: TextStyle(
        color: Colors.blueGrey.shade600,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    ),
  );
}

ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: Colors.blueGrey.shade600),
    title: Text(title, style: TextStyle(color: Colors.blueGrey.shade800)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    minLeadingWidth: 20,
    onTap: onTap,
  );
}

Widget _buildDrawerFooter(context) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        const Divider(),
        const SizedBox(height: 12),
        TextButton.icon(
          icon: Icon(Icons.logout, color: Colors.red.shade600),
          label: Text(
            'Sign Out',
            style: TextStyle(color: Colors.red.shade600),
          ),
          onPressed: () => _confirmLogout(context),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

Future<void> _confirmLogout(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          onPressed: () async {
            Navigator.pop(context);
            await logout(context);
          },
        ),
      ],
    ),
  );
}

logout(BuildContext context) {
  FirebaseAuth.instance.signOut();
}
