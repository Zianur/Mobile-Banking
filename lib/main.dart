import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_banking_flutter_firebase_app/screens/home_screen.dart';
import 'package:mobile_banking_flutter_firebase_app/screens/signin_screen.dart';
import 'package:mobile_banking_flutter_firebase_app/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Function to check the sign-in status
  Future<bool> _checkSignInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSignedIn') ?? false; // Return false if not signed in
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      home: FutureBuilder<bool>(
        future: _checkSignInStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while checking sign-in status
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            bool isSignedIn = snapshot.data ?? false;
            // Navigate to HomeScreen if signed in, otherwise SignUpScreen
            return isSignedIn ? HomeScreen() : SignUpScreen();
          }
        },
      ),
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
