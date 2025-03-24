import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'messaging/chatScreen.dart'; // Import your ChatScreen

import 'DashBoardForWorker.dart';
import 'RoleSelectionPage.dart';
import 'SignInPage.dart';
import 'auth_wrapper.dart';
import 'bottomNavigationBar/customBottomNavigationBar.dart';
import 'bottomNavigationBar/employerProfile.dart';
import 'bottomNavigationBar/history.dart';
import 'bottomNavigationBar/messages.dart';
import 'bottomNavigationBar/notification.dart';
import 'signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final user = FirebaseAuth.instance.currentUser;
  late final String _currentUserId = user?.uid ?? 'yourUserId';
  final databaseRef = FirebaseDatabase.instance.ref();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Handle individual connectivity result
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      onGenerateRoute: generateRoute,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for Firebase initialization
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasData && snapshot.data != null) {
            // If the user is signed in, navigate to Dashboardforworker
            return const CustomBottomNavBar();
          } else {
            // If the user is not signed in, navigate to SignIn page
            return const SignInPage();
          }
        },
      ),
    );
  }
}

// Route generation function
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/getStarted':
      return MaterialPageRoute(builder: (context) => const SignupScreen());
    case '/signUp':
      return MaterialPageRoute(builder: (context) => const SignupScreen());
    case '/signIn':
      return MaterialPageRoute(builder: (context) => const SignInPage());
    case '/dashBoardForWorker':
      return MaterialPageRoute(
          builder: (context) => const Dashboardforworker());
    case '/roleSelectionPage':
      return MaterialPageRoute(builder: (context) => const RoleSelectionPage());
    case '/history':
      return MaterialPageRoute(builder: (context) => const JobHistoryPage());
    case '/notification':
      return MaterialPageRoute(builder: (context) => NotificationsPage());
    case '/messages':
      return MaterialPageRoute(builder: (context) => const MessagePage());
    case '/employerProfile':
      return MaterialPageRoute(builder: (context) => const EmployerProfile());
    case '/CustomBottomNavBar':
      return MaterialPageRoute(
          builder: (context) => const CustomBottomNavBar());
    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}
