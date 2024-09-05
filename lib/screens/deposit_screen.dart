import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepositScreen extends StatefulWidget {
  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool isLoading = false;

  Future<void> _depositFunds() async {
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

      transaction.update(userDoc, {
        'currentBalance': currentBalance + amount,
        'availableBalance': availableBalance + amount,
      });

      transaction.set(
        userDoc.collection('transactions').doc(),
        {
          'type': 'Deposit',
          'amount': amount,
          'timestamp': Timestamp.now(),
        },
      );
    });

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deposit Funds')),
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
              onPressed: _depositFunds,
              child: Text('Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}
