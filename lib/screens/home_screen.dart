import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_banking_flutter_firebase_app/dashboard_screen.dart';
import 'package:mobile_banking_flutter_firebase_app/screens/fund_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/loading_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //storing sign in status for log out
  Future<void> _logOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', false); // Update sign-in status to false
  }

  void _signOut(BuildContext context) async {

    showLoadingDialog(context, message: 'Signing up...'); // Show loading dialog
    _logOut(context);//updating sign in status
    await _auth.signOut();
    hideLoadingDialog(context);//stopping loading dialog
    Navigator.pushReplacementNamed(context, '/signin');
  }

  //Bottom navigation bar
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    FundDetailsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body:_screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Fund Details',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
