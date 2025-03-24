import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  bool _isPasswordHidden = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;

  Future<bool> _signUp(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User created successfully!')));
      }
      return true; // Return true if signup is successful
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return false; // Return false if signup failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('SignUp', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset('assets/labour_services_logo.png'),
                ),

                const SizedBox(
                  height: 40,
                ),

                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'Username ',
                    labelStyle:
                        const TextStyle(color: Colors.grey, fontSize: 16), // Custom label style
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                      borderSide: const BorderSide(
                          color: Colors.orangeAccent, width: 2), // Border color and thickness
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Colors.orangeAccent, width: 2), // Border color when focused
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Colors.grey, width: 1), // Border color when not focused
                    ),
                    filled: true,
                    fillColor: Colors.white, // Background color
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15), // Padding inside the text field
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  obscureText: _isPasswordHidden,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordHidden = !_isPasswordHidden;
                          });
                        },
                        icon: Icon(
                            _isPasswordHidden == true ? Icons.visibility : Icons.visibility_off)),

                    labelText: 'Password ',
                    labelStyle:
                        const TextStyle(color: Colors.grey, fontSize: 16), // Custom label style
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                      borderSide: const BorderSide(
                          color: Colors.orangeAccent, width: 2), // Border color and thickness
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Colors.orangeAccent, width: 2), // Border color when focused
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Colors.grey, width: 1), // Border color when not focused
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15), // Padding inside the text field
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: 400,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool signUpSuccess =
                            await _signUp(_emailController.text, _passwordController.text);
                        if (signUpSuccess && context.mounted) {
                          // Only navigate if signup was successful
                          Navigator.pushNamed(context, 'roleSelectionPage');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Signup',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                    //signup
                    ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have account? '),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, 'signIn');
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 50,
                ),
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('or'),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ), //divider
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 400,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      User? user = await signInWithGoogle(context);

                      // if (user != null) {
                      //   if (context.mounted) {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //         const SnackBar(content: Text('User signed in successfully!')));
                      //     Navigator.pushNamed(context, 'dashBoardForWorker');
                      //   }
                      // } else {
                      //   if (context.mounted) {
                      //     ScaffoldMessenger.of(context)
                      //         .showSnackBar(const SnackBar(content: Text('Sign-in failed!')));
                      //   }
                      // }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      side: const BorderSide(width: 1, color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/GG.png',
                          alignment: Alignment.center,
                          height: 20,
                          width: 20,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text('SignUp with Google', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

Future<User?> signInWithGoogle(BuildContext context) async {
  final googleSignIn = GoogleSignIn();
  final auth = FirebaseAuth.instance;
  try {
    final GoogleSignInAccount? userInfo = await googleSignIn.signIn();

    if (userInfo != null) {
      final GoogleSignInAuthentication googleAuth = await userInfo.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final UserCredential userCredential = await auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-in successful!')),
        );
      }

      return userCredential.user; // Return the signed-in user
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-in was cancelled by the user')),
      );
      return null; // User cancelled the sign-in process
    }
  } catch (e, stacktrace) {
    // Display a more detailed error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign-in failed: ${e.toString()}')),
    );
    print('Google Sign-in Error: $e');
    print('Stacktrace: $stacktrace');
    return null; // Return null if sign-in fails
  }
}
