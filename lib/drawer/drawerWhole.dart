import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart'; // Import the provider file

Drawer buildNavigationDrawer(context, ref) {
  return Drawer(
    child: Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),

          _buildDrawerSectionHeader('Account'),
          _buildDrawerItem(Icons.person, 'My Profile', () {}),
          _buildDrawerItem(Icons.payment, 'Payment Methods', () {}),
          _buildDrawerItem(Icons.settings, 'App Settings', () {}),
          const Divider(height: 1),
          _buildDrawerSectionHeader('Support'),
          _buildDrawerItem(Icons.help, 'Help Center', () {}),
          _buildDrawerItem(Icons.phone, 'Contact Us', () {}),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 25),
          // Theme Switch
          _buildThemeSwitchTile(context, ref),
          _buildDrawerFooter(context),
        ],
      ),
    ),
  );
}

Widget _buildDrawerHeader() {
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

Widget _buildThemeSwitchTile(BuildContext context, WidgetRef ref) {
  final isDark = ref.watch(isDarkProvider);

  return GestureDetector(
    onTap: () {
      ref.read(isDarkProvider.notifier).state = !isDark;
    },
    child: Container(
        padding: const EdgeInsets.only(right: 35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDark ? 'Dark Mode' : 'Light Mode',
                      style: TextStyle(
                        // fontSize: 18,s
                        // fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white : Colors.blueGrey.shade800,
                      ),
                    ),
                    // const SizedBox(height: 2),
                  ],
                ),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.blueGrey.shade700, Colors.grey.shade800]
                      : [Colors.amber.shade200, Colors.orange.shade200],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    left: isDark ? 32 : 2,
                    right: isDark ? 2 : 32,
                    child: Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isDark
                            ? Icon(
                                Icons.dark_mode,
                                key: const ValueKey('moon-icon'),
                                size: 16,
                                color: Colors.blueGrey.shade800,
                              )
                            : Icon(
                                Icons.light_mode,
                                key: const ValueKey('sun-icon'),
                                size: 16,
                                color: Colors.orange.shade600,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
  );
}

logout(BuildContext context) {
  FirebaseAuth.instance.signOut();
}
