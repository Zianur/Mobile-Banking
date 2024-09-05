import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFundSummary(),
            SizedBox(height: 20),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  // Widget to display fund summary
  Widget _buildFundSummary() {
    // Placeholder data; replace with actual data fetched from your backend or database
    double currentFunds = 5000.00;
    double availableFunds = 4500.00;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fund Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Current Funds: \$${currentFunds.toStringAsFixed(2)}'),
            Text('Available Funds: \$${availableFunds.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  // Widget to display recent transactions
  Widget _buildRecentTransactions() {
    // Placeholder data; replace with actual data fetched from your backend or database
    List<Map<String, String>> transactions = [
      {'date': '2024-09-04', 'type': 'Deposit', 'amount': '\$500'},
      {'date': '2024-09-03', 'type': 'Withdrawal', 'amount': '\$200'},
      {'date': '2024-09-02', 'type': 'Transfer', 'amount': '\$300'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('${transactions[index]['type']}'),
              subtitle: Text('${transactions[index]['date']}'),
              trailing: Text('${transactions[index]['amount']}'),
            );
          },
        ),
      ],
    );
  }
}
