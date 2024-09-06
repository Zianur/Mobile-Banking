import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  bool isLoading = false;

  // Function to handle the transfer process
  Future<void> _transferFunds() async {
    setState(() {
      isLoading = true;
    });

    double amount = double.parse(_amountController.text);
    String recipientMobileNumber = _mobileNumberController.text;
    String senderUid = FirebaseAuth.instance.currentUser!.uid;

    // Reference to the sender's document in Firestore
    DocumentReference senderDoc = FirebaseFirestore.instance.collection('users').doc(senderUid);

    // Find the recipient document using their mobile number
    QuerySnapshot recipientSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('mobileNumber', isEqualTo: recipientMobileNumber)
        .limit(1)
        .get();

    if (recipientSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipient not found')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    DocumentReference recipientDoc = recipientSnapshot.docs.first.reference;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot senderSnapshot = await transaction.get(senderDoc);
      DocumentSnapshot recipientSnapshot = await transaction.get(recipientDoc);

      double senderCurrentBalance = senderSnapshot['currentBalance'];
      double senderAvailableBalance = senderSnapshot['availableBalance'];
      double recipientCurrentBalance = recipientSnapshot['currentBalance'];
      double recipientAvailableBalance = recipientSnapshot['availableBalance'];

      if (senderAvailableBalance >= amount) {
        // Update sender's balances
        transaction.update(senderDoc, {
          'currentBalance': senderCurrentBalance - amount,
          'availableBalance': senderAvailableBalance - amount,
        });

        // Update recipient's balances
        transaction.update(recipientDoc, {
          'currentBalance': recipientCurrentBalance + amount,
          'availableBalance': recipientAvailableBalance + amount,
        });

        // Add transaction record for sender
        transaction.set(
          senderDoc.collection('transactions').doc(),
          {
            'type': 'Transfer Out',
            'amount': amount,
            'timestamp': Timestamp.now(),
            'recipient': recipientMobileNumber,
          },
        );

        // Add transaction record for recipient
        transaction.set(
          recipientDoc.collection('transactions').doc(),
          {
            'type': 'Transfer In',
            'amount': amount,
            'timestamp': Timestamp.now(),
            'sender': FirebaseAuth.instance.currentUser!.phoneNumber,
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
      appBar: AppBar(title: Text('Transfer Funds')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _mobileNumberController,
              decoration: InputDecoration(labelText: 'Recipient Mobile Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _transferFunds,
              child: Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
