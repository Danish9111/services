import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/drawer/contact_us.dart';
import '../providers.dart'; // Import the provider file
import 'package:services/drawer/helpCenter.dart';
import 'dart:io';
import 'package:services/bottomNavigationBar/profile.dart';
import 'package:firebase_database/firebase_database.dart';

Drawer buildNavigationDrawer(context, ref) {
  final userEmail = ref.watch(userEmailProvider) ?? '';
  final userName = ref.watch(userNameProvider) ?? '';
  final darkColorPro = ref.watch(darkColorProvider);
  final lightColorPro = ref.watch(lightColorProvider);
  final imageUrl = ref.watch(profileImageProvider) ?? "";

  return Drawer(
    child: Container(
      color: darkColorPro,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(userEmail, userName, imageUrl),

          _buildDrawerSectionHeader(
              'Account', darkColorPro, Colors.orangeAccent),
          _buildDrawerItem(Icons.person, 'My Profile', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EmployerProfile()),
            );
          }, darkColorPro, Colors.orangeAccent, lightColorPro),
          // _buildDrawerItem(Icons.payment, 'Payment Methods', () {},
          //     darkColorPro, Colors.orangeAccent, lightColorPro),

          // _buildDrawerItem(Icons.settings, 'App Settings', () {}, darkColorPro,
          //     Colors.orangeAccent, lightColorPro),
          // const Divider(height: 1),
          _buildDrawerSectionHeader(
              'Support', darkColorPro, Colors.orangeAccent),
          _buildDrawerItem(Icons.help, 'Help Center', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HelpCenterPage()),
            );
          }, darkColorPro, Colors.orangeAccent, lightColorPro),
          _buildDrawerItem(Icons.phone, 'Contact Us', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ContactUsPage()),
            );
          }, darkColorPro, Colors.orangeAccent, lightColorPro),
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

Widget _buildDrawerHeader(String userEmail, String userName, String imageUrl) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Color.fromARGB(255, 63, 72, 76),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[200],
          child: Builder(
            builder: (_) {
              try {
                if (imageUrl.isNotEmpty) {
                  if (imageUrl.startsWith('http')) {
                    // Network image
                    return CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(imageUrl),
                    );
                  } else {
                    // Local file image
                    return CircleAvatar(
                      radius: 40,
                      backgroundImage: FileImage(File(imageUrl)),
                    );
                  }
                } else {
                  return const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/default_pic.png'),
                  );
                }
              } catch (e) {
                debugPrint('❌Error loading profile image: $e');
                return const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/default_pic.png'),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          userName,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // Text(
        //   userEmail,
        //   style: const TextStyle(color: Colors.white),
        // ),
      ],
    ),
  );
}

Widget _buildDrawerSectionHeader(
    String title, Color darkColorPro, Color lightColorPro) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(
      title,
      style: TextStyle(
        color: lightColorPro,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    ),
  );
}

ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
    Color darkColorPro, orangeAccent, lightColorPro) {
  return ListTile(
    leading: Icon(icon, color: orangeAccent),
    title: Text(title, style: TextStyle(color: lightColorPro)),
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
          onPressed: () => _confirmLogoutDialog(context),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

Future<void> _confirmLogoutDialog(BuildContext context) async {
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

Future<void> logout(BuildContext context) async {
  final databaseRef = FirebaseDatabase.instance.ref();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  if (currentUserId.isNotEmpty) {
    try {
      await databaseRef.child('users/$currentUserId/online').set(false);
      await databaseRef
          .child('users/$currentUserId/lastSeen')
          .set(ServerValue.timestamp);
      debugPrint('✅ Successfully set user offline');
    } catch (e) {
      debugPrint('❌ Error setting offline: $e');
    }
  }

  // Now safely sign out AFTER setting offline
  await FirebaseAuth.instance.signOut();
}
