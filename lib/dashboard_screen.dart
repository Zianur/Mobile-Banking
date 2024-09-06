import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color(0xFF093C65),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildBalanceSection(),
                  ),
                  SizedBox(height: 20),
                  _buildTransactionButtons(context),
                  SizedBox(height: 20),
                ],
              )
          ),
          SizedBox(height: 20),
          Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8,0,0,0),
                child: Text("Transactions in last 7 days"),
              )
          ),
          Divider(
              color: Colors.black
          ),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  // Section to display user's current and available balance
  Widget _buildBalanceSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var userDoc = snapshot.data!;
        double currentBalance = userDoc['currentBalance'] ?? 0.0;
        double availableBalance = userDoc['availableBalance'] ?? 0.0;
        String email = userDoc['email']?? "Email";
        String mobileNumber = userDoc['mobileNumber']?? "Mobile Number";

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$email', style: TextStyle(fontSize: 10)),
                Text('$mobileNumber', style: TextStyle(fontSize: 20)),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Current Balance', style: TextStyle(fontSize: 14)),
                        Text('\$${currentBalance.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
                      ],
                    ),

                    Column(
                      children: [
                        Text('Available Balance', style: TextStyle(fontSize: 14)),
                        Text('\$${availableBalance.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Buttons for deposit, withdraw, and transfer
  Widget _buildTransactionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/deposit'),
          child: Text('Deposit'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/withdraw'),
          child: Text('Withdraw'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/transfer'),
          child: Text('Transfer'),
        ),
      ],
    );
  }

  // Display recent transactions or a message if no transactions are found
  Widget _buildRecentTransactions() {
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var transactions = snapshot.data!.docs;

          if (transactions.isEmpty) {
            // Display message if no transactions exist
            return Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Display list of transactions
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction = transactions[index];
              return Card(
                child: ListTile(
                  title: Text('${transaction['type']} - \$${transaction['amount'].toStringAsFixed(2)}'),
                  subtitle: Text(transaction['timestamp'].toDate().toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
