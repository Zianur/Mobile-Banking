import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool isLoading = false;

  // Function to handle the withdrawal process
  Future<void> _withdrawFunds() async {
    setState(() {
      isLoading = true;
    });

    double amount = double.parse(_amountController.text);
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDoc);

      double currentBalance = snapshot['currentBalance'];
      double availableBalance = snapshot['availableBalance'];

      if (availableBalance >= amount) {
        // Update balances
        transaction.update(userDoc, {
          'currentBalance': currentBalance - amount,
          'availableBalance': availableBalance - amount,
        });

        // Add the transaction record
        transaction.set(
          userDoc.collection('transactions').doc(),
          {
            'type': 'Withdraw',
            'amount': amount,
            'timestamp': Timestamp.now(),
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient balance')),
        );
      }
    });

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Withdraw Funds')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _withdrawFunds,
                    child: Text('Withdraw'),
                  ),
          ],
        ),
      ),
    );
  }
}
