import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:another_flushbar/flushbar.dart';

import '../DashBoardForWorker.dart';
import 'employerProfile.dart';
import 'history.dart';
import 'messages.dart';

final String uId = FirebaseAuth.instance.currentUser!.uid;

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  CustomBottomNavBarState createState() => CustomBottomNavBarState();
}

class CustomBottomNavBarState extends State<CustomBottomNavBar> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();
    _listenForUnreadMessages();
  }

  int _unreadMessages = 0;
  bool _isBadgeVisible = true;

  void _listenForUnreadMessages() {
    FirebaseFirestore.instance
        .collection('chatss')
        .where('receiverId', isEqualTo: uId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((event) {
      try {
        // Check if there are unread messages and you're not in the Messages tab (index 2)
        if (event.docs.isNotEmpty && _controller.index != 2) {
          setState(() {
            _unreadMessages = event.docs.length;
            _isBadgeVisible = _unreadMessages > 0;

            // Show Flushbar notification for new unread messages
            Flushbar(
              title: "Success",
              message: "You have $_unreadMessages new messages!",
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color.fromARGB(255, 184, 233, 255),
              borderRadius: BorderRadius.circular(8),
              margin: const EdgeInsets.all(10),
              flushbarPosition: FlushbarPosition.TOP, // or BOTTOM
            ).show(context);
          });
        } else {
          setState(() {
            _isBadgeVisible = false;
          });
        }
      } catch (e) {
        // Log the error for better debugging
        print('Error fetching unread messages: $e');

        // Show error to user
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
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.orangeAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.history),
        title: "History",
        activeColorPrimary: Colors.orangeAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: badges.Badge(
          showBadge: _isBadgeVisible, // Show badge only on the messages tab
          badgeColor: Colors.redAccent,
          borderSide: const BorderSide(color: Colors.white, width: 1),
          position: badges.BadgePosition.topEnd(top: -10, end: -10),
          badgeContent: Text(
            _unreadMessages.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          child: const Icon(
            Icons.chat,
          ),
        ),
        title: "Messages",
        activeColorPrimary: Colors.orangeAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.account_circle),
        title: "Profile",
        activeColorPrimary: Colors.orangeAccent,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      padding: const EdgeInsets.symmetric(vertical: 15),
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: false,
      stateManagement: true,
      navBarStyle: NavBarStyle.style8,
      navBarHeight: 80,
      onItemSelected: (index) {
        if (index == 2) {
          // Hide the badge when the "Messages" tab is selected
          setState(() {
            _isBadgeVisible = false;
          });
        }
      },
    );
  }
}
