import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryPage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('History')
            // Filter by user ID
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(); // Loading indicator
          }
          final orderHistory = snapshot.data?.docs; // List of order documents
          return ListView.builder(
            itemCount: orderHistory?.length,
            itemBuilder: (context, index) {
              final order = orderHistory![index];
              final title = order['title'];
              final imageUrl = order['imageUrl'];
              final price = order['price'];
              final quantity = order['quantity'];

              return ListTile(
                title: Text(title),
                subtitle: Text('Price: $price | Quantity: $quantity'),
                leading: Image.network(imageUrl),
              );
            },
          );
        },
      ),
    );
  }
}
