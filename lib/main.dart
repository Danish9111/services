import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'DashBoardForWorker.dart';
import 'RoleSelectionPage.dart';
import 'SignInPage.dart';
import 'bottomNavigationBar/customBottomNavigationBar.dart';
import 'bottomNavigationBar/profile.dart';
import 'bottomNavigationBar/history.dart';
import 'bottomNavigationBar/messages.dart';
import 'bottomNavigationBar/notification.dart';
import 'signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:shared_preferences/shared_preferences.dart';
import 'providers.dart'; // import your provider
import 'package:flutter/services.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFB3E5FC), // light blue
    statusBarIconBrightness: Brightness.dark, // dark icons for light background
  ));
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  // Load image path from SharedPreferences and update provider
  final prefs = await SharedPreferences.getInstance();
  final imagePath = prefs.getString('profile_image_path') ?? '';
  final container = ProviderContainer();
  container.read(profileImageProvider.notifier).state = imagePath;

  await sb.Supabase.initialize(
    url: 'https://wclstppljeelcmaoejba.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndjbHN0cHBsamVlbGNtYW9lamJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwMzEyNjgsImV4cCI6MjA2MDYwNzI2OH0.a7pKTr7NX0j6v_MLrcXuFUmnxPPXKoKn8uMaQSBEzek',
  );
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug,
  // );
  // String? token = await FirebaseAppCheck.instance.getToken();
  // debugPrint('🤣App Check token: $token');

  runApp(
    ProviderScope(
      overrides: [
        profileImageProvider.overrideWith((ref) => imagePath),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  User? user;
  String? _currentUserId;
  final databaseRef = FirebaseDatabase.instance.ref();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isOnline = false;
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('chatss')
        .where('status', isEqualTo: 'sent')
        .where('receiverId', isEqualTo: _currentUserId)
        .snapshots()
        .listen((event) {
      updateMessageToReceived(event.docs);
    });

    // Set up the observer for app lifecycle
    WidgetsBinding.instance.addObserver(this);

    // Listen for authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      setState(() {
        user = firebaseUser;
        if (user != null) {
          _currentUserId = user?.uid;
          _setUserOnlineStatus(true); // Set online immediately when logged in

          // Attach Firestore listener for messages
          // FirebaseFirestore.instance
          //     .collection('chatss')
          //     .where('receiverId', isEqualTo: _currentUserId)
          //     .where('status', isEqualTo: 'sent')
          //     .orderBy('timestamp', descending: false)
          //     .snapshots()
          //     .listen((snapshot) {
          //   updateMessageToReceived(snapshot.docs);
          // });
        } else {
          _setUserOnlineStatus(false);
        }
      });
    });

    // Listen for connectivity changes (optional)
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
      if (!_isOnline) {
        _setUserOnlineStatus(false);
      } else if (user != null) {
        _setUserOnlineStatus(true);
      }
    });

    // If a user is already logged in at startup, set online status to true
    if (user != null) {
      _setUserOnlineStatus(true);
    }
    _setUserOnlineStatus(true);
  }

  void updateMessageToReceived(List<QueryDocumentSnapshot> messages) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final unreceivedMessages =
        messages.where((message) => message['status'] != 'received').toList();

    if (unreceivedMessages.isNotEmpty) {
      try {
        for (var messageDoc in unreceivedMessages) {
          if (messageDoc['receiverId'] == currentUserId) {
            FirebaseFirestore.instance
                .collection('chatss')
                .doc(messageDoc.id)
                .update({'status': 'received'});
          }
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (user != null) {
      if (state == AppLifecycleState.resumed) {
        // App has come to the foreground – set status to online
        _setUserOnlineStatus(true);
      } else {
        // App is not in the foreground – set status to offline
        _setUserOnlineStatus(false);
      }
    }
  }

  //stop here////////////////////

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    _setUserOnlineStatus(false); // Ensure status is offline on dispose
    super.dispose();
  }

  void _setUserOnlineStatus(bool isOnline) {
    if (user != null && _currentUserId != null) {
      databaseRef.child('users/$_currentUserId/online').set(isOnline);
      if (!isOnline) {
        databaseRef
            .child('users/$_currentUserId/lastSeen')
            .set(ServerValue.timestamp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
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
