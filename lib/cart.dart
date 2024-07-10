import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:miron/favourites.dart';
import 'package:miron/model/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  List<QueryDocumentSnapshot>? cartItems;
  late String selectedDeliveryOption;

  double? distanceInMeter = 0.0;
  String? userAddress;

  @override
  void initState() {
    super.initState();

    fetchCartItems();
  }

//----------------------------------------------------------------------------
  double calculateFinalCartPrice() {
    double totalCartPrice = 0.0;

    if (cartItems != null) {
      for (final cartItem in cartItems!) {
        final data = cartItem.data() as Map<String, dynamic>;
        final price = double.parse(data['price']);
        final quantity = data['quantity'];
        final itemTotalPrice = price * quantity;

        totalCartPrice += itemTotalPrice;
      }
    }

    return totalCartPrice;
  }

  //----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: const Column(
          children: [
            Expanded(child: CartItemList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          placeOrder();
        },
        label: const Text('Place the Order'),
        icon: const Icon(Icons.shopping_bag),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Final Cart Price: \$${calculateFinalCartPrice().toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  //get the distance

  //place order

//place order
  Future<void> placeOrder() async {
    final cartItemsSnapshot =
        await FirebaseFirestore.instance.collection('cartItems').get();

    if (cartItemsSnapshot.docs.isNotEmpty) {
      for (final item in cartItemsSnapshot.docs) {
        final data = item.data() as Map<String, dynamic>;
        final title = data['title'];
        final price = data['price'];
        final imageUrl = data['imageUrl'];
        final quantity = data['quantity'];

        // Get the current user's ID
        final User? user = _auth.currentUser;
        if (user != null) {
          final userId = user.uid;

          // Generate a new order ID
          String? orderId = _databaseRef.child("Orders").push().key;

          // Get the current timestamp as a string
          String timestamp = DateTime.now().toLocal().toString();

          // Include user ID, timestamp, and selected delivery option in cart item data
          Map<String, dynamic> orderData = {
            "userid": userId, // Include the user's ID
            "orderid": orderId,
            "title": title,
            "price": price,
            "imageUrl": imageUrl,
            "quantity": quantity,
            "orderStatus": "Pending",

            "timestamp": timestamp, // Include the timestamp as a string
          };

          try {
            // Upload the order data to Realtime Database under "Orders"
            await _databaseRef.child("Orders").child(orderId!).set(orderData);

            // Delete the cart item from Firestore
            await FirebaseFirestore.instance
                .collection('cartItems')
                .doc(item.id)
                .delete();

            // Store order data in "History" collection in Firestore
            await FirebaseFirestore.instance
                .collection('History')
                .doc(
                    orderId) // Use the same orderId as the document ID in "History"
                .set(orderData);

            print("Order Placed");
          } catch (error) {
            print("Error placing order: $error");
          }
        } else {
          print("User is not authenticated.");
        }
        showOrderPlacedAlert();
      }
    }
  }

  Future<void> fetchCartItems() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      final cartItemsSnapshot = await FirebaseFirestore.instance
          .collection('cartItems')
          .where("userUID", isEqualTo: user.uid) // Filter by user's UID
          .get();

      setState(() {
        cartItems = cartItemsSnapshot.docs;
      });
    }
  }

  void showOrderPlacedAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Order Placed Successfully"),
          content: Text("Your order has been placed successfully."),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

// Function to retrieve and show the address

// Function to show the address in an AlertDialog

// alert dialog

class CartItemList extends StatelessWidget {
  const CartItemList({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cartItems').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final cartItems = snapshot.data!.docs;

        if (cartItems.isEmpty) {
          return const Center(
            child: Text(
              'Your cart is empty.',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final cartItem = cartItems[index];
            final data = cartItem.data() as Map<String, dynamic>;

            return CartItemTile(
              title: data['title'],
              price: data['price'].toString(),
              imageUrl: data['imageUrl'],
              quantity: data['quantity'],
              cartItem: cartItem,
            );
          },
        );
      },
    );
  }
}

class CartItemTile extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final int quantity;
  final QueryDocumentSnapshot cartItem;

  const CartItemTile({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.cartItem,
  });

  @override
  Widget build(BuildContext context) {
    final double priceDouble = double.parse(price);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Image.network(imageUrl, width: 80.0),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price: \$${priceDouble.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            Text(
              'Quantity: $quantity',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
            size: 30,
          ),
          onPressed: () {
            FirebaseFirestore.instance
                .collection('cartItems')
                .doc(cartItem.id)
                .delete()
                .then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item removed from cart.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error removing item from cart: $error'),
                  duration: const Duration(seconds: 2),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
