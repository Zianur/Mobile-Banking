import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/loading_dialog.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signIn() async {

    showLoadingDialog(context, message: 'Signing up...'); // Show loading dialog

    try {
      // Sign in with email and password
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      //Sign in State checking
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSignedIn', true); // Save sign-in state

      hideLoadingDialog(context); // Hide loading dialog

      // Navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      hideLoadingDialog(context); // Hide loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: Text('Don\'t have an account? Sign Up'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
