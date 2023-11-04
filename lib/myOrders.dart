import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:miron/history.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({Key? key}) : super(key: key);

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  final User? _user =
      FirebaseAuth.instance.currentUser; // Get the authenticated user
  List<dynamic>? _orders;

  @override
  void initState() {
    super.initState();

    if (_user != null) {
      final currentUserUID = _user?.uid;

      // Listen for changes to the Orders collection where userid matches the current user's UID.
      _databaseRef
          .child('Orders')
          .orderByChild('userid')
          .equalTo(currentUserUID)
          .onValue
          .listen((event) {
        setState(() {
          _orders = (event.snapshot.value as Map?)?.values.toList();
        });
      });
    }
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
    await _databaseRef.child('Orders').child(orderId).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Café Miron',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                InkWell(
                  // This is your link to OrderHistoryPage
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderHistoryPage()),
                    );
                  },
                  child: const Text(
                    'View Order History',
                    style: TextStyle(
                      color: Colors.blue, // You can customize the link's color
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Add spacing
                _orders == null
                    ? const CircularProgressIndicator()
                    : _orders!.isEmpty
                        ? const Text('No orders available')
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _orders!.length,
                              itemBuilder: (context, index) {
                                final item = _orders![index];
                                final imageUrl = item['imageUrl'] ?? '';
                                final title = item['title'] ?? '';
                                final quantity =
                                    parseValue(item['quantity'] ?? '0');
                                final price = parseValue(item['price'] ?? '0');
                                final total = calculateTotalPrice(item);
                                final deliveryOption =
                                    item['deliveryOption'] ?? '';
                                final orderStatus = item['orderStatus'];

                                return Card(
                                  elevation: 3,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: ListTile(
                                      contentPadding: const EdgeInsets.all(20),
                                      title: Text(
                                        'Item: $title',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Quantity: $quantity',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            'Price: \$${price.toStringAsFixed(2)}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            'Total Price: \$${total.toStringAsFixed(2)}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            'Delivery Option: $deliveryOption', // Display the delivery option
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            'Order Status: $orderStatus', // Display the status
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 8),
                                          Image.network(
                                            imageUrl,
                                            width: 100,
                                            height: 100,
                                          ),
                                        ],
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () {
                                          // Check if the order status is "Pending" before allowing cancellation
                                          if (orderStatus == 'Pending') {
                                            // Show a confirmation dialog for cancellation
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Cancel Order'),
                                                  content: const Text(
                                                      'Are you sure you want to cancel this order?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('No'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text('Yes'),
                                                      onPressed: () async {
                                                        // Get the orderId of the order to be canceled
                                                        final orderId =
                                                            item['orderid'] ??
                                                                '';

                                                        // Check if orderId is not an empty string before canceling the order
                                                        if (orderId
                                                            .isNotEmpty) {
                                                          // Implement cancellation logic here

                                                          // 1. Remove the order with the specified orderId from Firebase Realtime Database
                                                          await _databaseRef
                                                              .child('Orders')
                                                              .child(orderId)
                                                              .remove();

                                                          // Now, the order is deleted from Firebase Realtime Database.
                                                        }

                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            // If the order status is not "Pending," show a message in an alert dialog
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Cannot Cancel Order'),
                                                  content: const Text(
                                                      'This order cannot be canceled because it is not in "Pending" status.'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('OK'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: const Text('Cancel Order'),
                                      )),
                                );
                              },
                            ),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
