import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FundDetailsScreen extends StatefulWidget {
  @override
  _FundDetailsScreenState createState() => _FundDetailsScreenState();
}

class _FundDetailsScreenState extends State<FundDetailsScreen> {
  List<TransactionData> transactions = [];
  String filter = 'Day'; // Default filter

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  // Fetch transactions based on the selected filter
  Future<void> _fetchTransactions() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .get();

    List<TransactionData> allTransactions = querySnapshot.docs.map((doc) {
      return TransactionData(
        type: doc['type'],
        amount: doc['amount'].toDouble(),
        timestamp: doc['timestamp'].toDate(),
      );
    }).toList();

    setState(() {
      transactions = _filterTransactions(allTransactions);
    });
  }

  // Filter transactions based on the selected filter (Day, Week, Month, Year)
  List<TransactionData> _filterTransactions(List<TransactionData> allTransactions) {
    DateTime now = DateTime.now();
    DateTime start;

    switch (filter) {
      case 'Day':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
    }

    return allTransactions.where((transaction) {
      return transaction.timestamp.isAfter(start);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [ 
          Container(
            color: Color(0xFF093C65),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Container(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8,0,8,0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: filter,
                          items: ['Day', 'Week', 'Month', 'Year']
                              .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                              .toList(),
                          onChanged: (newValue) {
                            setState(() {
                              filter = newValue!;
                              _fetchTransactions();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(child: Text('No transactions yet'))
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(),
                      title: ChartTitle(text: 'Transactions Overview'),
                      legend: Legend(isVisible: false),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <ChartSeries<TransactionData, DateTime>>[
                        ColumnSeries<TransactionData, DateTime>(
                          dataSource: transactions,
                          xValueMapper: (TransactionData data, _) => data.timestamp,
                          yValueMapper: (TransactionData data, _) => data.amount,
                          name: 'Transactions',
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("All Transactions"),
                  Divider(
                      color: Colors.black
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text('${transactions[index].type} - \$${transactions[index].amount}'),
                            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(transactions[index].timestamp)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model class to represent transaction data
class TransactionData {
  final String type;
  final double amount;
  final DateTime timestamp;

  TransactionData({
    required this.type,
    required this.amount,
    required this.timestamp,
  });
}
