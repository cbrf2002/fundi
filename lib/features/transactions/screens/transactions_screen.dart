import 'package:flutter/material.dart';

class TransactionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with actual data.
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Transaction $index'),
            subtitle: Text('Amount: \$${index * 10}'),
            leading: Icon(Icons.attach_money),
          );
        },
      ),
    );
  }
}
