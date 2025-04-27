import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../DashBoardForWorker.dart';
import 'profile.dart';
import 'history.dart';
import 'messages.dart';

final String uId = FirebaseAuth.instance.currentUser!.uid;

class CustomBottomNavBar extends ConsumerStatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  CustomBottomNavBarState createState() => CustomBottomNavBarState();
}

class CustomBottomNavBarState extends ConsumerState<CustomBottomNavBar> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();
    _listenForUnreadMessages();
  }

  int _unreadMessages = 0;
  bool _isBadgeVisible = false;

  void _listenForUnreadMessages() {
    FirebaseFirestore.instance
        .collection('chatss')
        .where('receiverId', isEqualTo: uId)
        .where('status',
            whereIn: ['sent', 'received']) // Instead of isNotEqualTo
        .snapshots()
        .listen((event) {
          try {
            setState(() {
              _unreadMessages = event.docs.length;
              _isBadgeVisible = _unreadMessages > 0;
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
              ),
            );
          }
        });
  }

  List<Widget> _buildScreens() {
    return [
      const Dashboardforworker(),
      const JobHistoryPage(),
      const MessagePage(),
      const EmployerProfile(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    // final darkColorPro = ref.watch(darkColorProvider);
    final lightColorPro = ref.watch(lightColorProvider);
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.orangeAccent,
        inactiveColorPrimary: lightColorPro,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.history),
        title: "History",
        activeColorPrimary: Colors.orangeAccent,
        inactiveColorPrimary: lightColorPro,
      ),
      PersistentBottomNavBarItem(
        icon: badges.Badge(
          showBadge: _isBadgeVisible, // Show badge only on the messages tab
          badgeColor: Colors.redAccent,
          borderSide: const BorderSide(color: Colors.white, width: 1),
          position: badges.BadgePosition.topEnd(top: -10, end: -10),
          badgeContent: Text(
            _unreadMessages.toString(),
            style: TextStyle(color: lightColorPro),
          ),
          child: const Icon(
            Icons.chat,
          ),
        ),
        title: "Messages",
        activeColorPrimary: Colors.orangeAccent,
        inactiveColorPrimary: lightColorPro,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.account_circle),
        title: "Profile",
        activeColorPrimary: Colors.orangeAccent,
        inactiveColorPrimary: lightColorPro,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final darkColorPro = ref.watch(darkColorProvider);
    // final lightColorPro = ref.watch(lightColorProvider);

    return WillPopScope(
        onWillPop: () async {
          // Check if the root navigator can pop
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return false;
          }
          return true; // Allow app to close
        },
        child: Container(
          child: PersistentTabView(
            padding: const EdgeInsets.symmetric(vertical: 15),
            context,
            controller: _controller,
            screens: _buildScreens(),
            items: _navBarsItems(),
            confineToSafeArea: true,
            backgroundColor: darkColorPro,
            handleAndroidBackButtonPress:
                false, // Disable built-in back handling
            resizeToAvoidBottomInset: false,
            stateManagement: true,
            navBarStyle: NavBarStyle.style8,
            navBarHeight: 80,
            onItemSelected: (index) {
              if (index == 2) {
                setState(() {
                  _isBadgeVisible = false;
                });
              }
            },
          ),
        ));
  }
}
