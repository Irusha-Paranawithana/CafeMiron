import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({Key? key}) : super(key: key);

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  List<dynamic>? _orders;

  @override
  void initState() {
    super.initState();

    // Listen for changes to the Orders collection.
    _database.child('Orders').onValue.listen((event) {
      setState(() {
        _orders = (event.snapshot.value as Map?)?.values.toList();
      });
    });
  }

  double calculateTotalPrice(dynamic item) {
    final quantity = parseValue(item['quantity']);
    final price = parseValue(item['price']);
    return quantity * price;
  }

  dynamic parseValue(dynamic value) {
    if (value is int || value is double) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    // Remove the order with the specified orderId from Firebase.
    await _database.child('Orders').child(orderId).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Café Miron'),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: _orders == null
                ? CircularProgressIndicator()
                : _orders!.isEmpty
                    ? Text('No orders available')
                    : ListView.builder(
                        itemCount: _orders!.length,
                        itemBuilder: (context, index) {
                          final item = _orders![index];
                          final imageUrl = item['imageUrl'] ?? '';
                          final title = item['title'] ?? '';
                          final quantity = parseValue(item['quantity'] ?? '0');
                          final price = parseValue(item['price'] ?? '0');
                          final total = calculateTotalPrice(item);

                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(20),
                              title: Text(
                                'Item: $title',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quantity: $quantity',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Price: \$${price.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Total Price: \$${total.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Image.network(
                                    imageUrl,
                                    width: 100,
                                    height: 100,
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // Show a confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Cancel Order'),
                                        content: Text(
                                            'Are you sure you want to cancel this order?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Yes'),
                                            onPressed: () async {
                                              // Get the orderId of the order to be canceled
                                              final orderId =
                                                  item['orderid'] ?? '';

                                              // Check if orderId is not an empty string before canceling the order
                                              if (orderId.isNotEmpty) {
                                                // Implement cancellation logic here

                                                // 1. Remove the order with the specified orderId from Firebase Realtime Database
                                                await _database
                                                    .child('Orders')
                                                    .child(orderId)
                                                    .remove();

                                                // 2. Delete the corresponding cart item from Firestore
                                                await FirebaseFirestore.instance
                                                    .collection('cartItems')
                                                    .where('orderid',
                                                        isEqualTo: orderId)
                                                    .get()
                                                    .then((querySnapshot) {
                                                  querySnapshot.docs
                                                      .forEach((doc) {
                                                    doc.reference.delete();
                                                  });
                                                });

                                                // Now, the order is deleted from both Firebase Realtime Database and Firestore.
                                              }

                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text('Cancel Order'),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
