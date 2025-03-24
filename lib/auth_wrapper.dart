// auth_wrapper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'SignInPage.dart';
import 'bottomNavigationBar/customBottomNavigationBar.dart';
//
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // When the connection is active, show the appropriate screen
//         if (snapshot.connectionState == ConnectionState.active) {
//           final user = snapshot.data;
//           // If there's no user, show the sign-in page
//           if (user == null) {
//             return const SignInPage();
//           }
//           // If there is a user, show the authenticated UI (with bottom nav bar)
//           else {
//             return CustomBottomNavBar();
//           }
//         }
//         // Otherwise, show a loading indicator
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       },
//     );
//   }
// }

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              try {
                return const SignInPage();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(e.toString()),
                ));
              }
            } else {
              return const CustomBottomNavBar();
            }
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
