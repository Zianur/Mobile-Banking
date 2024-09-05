import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  bool isLoading = true;
  double balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      user = _auth.currentUser;
      if (user != null) {
        // Fetch user's fund data from Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
        setState(() {
          balance = userDoc['balance'] ?? 0.0; // Fetching balance from Firestore
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _addFunds(double amount) async {
    // Add funds to user's balance
    setState(() {
      balance += amount;
    });
    await _firestore.collection('users').doc(user!.uid).update({'balance': balance});
  }

  void _withdrawFunds(double amount) async {
    // Withdraw funds if enough balance
    if (balance >= amount) {
      setState(() {
        balance -= amount;
      });
      await _firestore.collection('users').doc(user!.uid).update({'balance': balance});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient balance')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fund Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.email ?? 'User'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Balance: \$${balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _addFunds(100), // Example to add $100
                  child: Text('Add Funds'),
                ),
                ElevatedButton(
                  onPressed: () => _withdrawFunds(50), // Example to withdraw $50
                  child: Text('Withdraw Funds'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _buildTransactionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transactions').where('userId', isEqualTo: user?.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading transactions'));
        }

        final transactions = snapshot.data?.docs ?? [];

        if (transactions.isEmpty) {
          return Center(child: Text('No transactions found.'));
        }

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            var transaction = transactions[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(transaction['type']),
              subtitle: Text('Amount: \$${transaction['amount']}'),
              trailing: Text(transaction['date'].toDate().toString()),
            );
          },
        );
      },
    );
  }
}
