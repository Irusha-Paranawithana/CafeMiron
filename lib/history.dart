import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miron/model/colors.dart';

class OrderHistoryPage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // Handle the case when the user is not authenticated
      return Scaffold(
        appBar: AppBar(
          title: Text('Order History'),
        ),
        body: Center(
          child: Text('User is not authenticated.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('History')
            .where('userid', isEqualTo: user!.uid) // Filter by user ID
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _clearOrderHistory(context),
        tooltip: 'Clear Order History',
        child: Icon(Icons.delete),
      ),
    );
  }

  void _clearOrderHistory(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('History')
        .where('userid', isEqualTo: user?.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: mainColor,
        content: Text('Order history cleared'),
      ),
    );
  }
}
