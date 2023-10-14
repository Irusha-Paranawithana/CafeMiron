import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:miron/favourites.dart';
import 'package:miron/pages/Review.dart';
import 'package:miron/views/home.dart';
import 'package:firebase_database/firebase_database.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Color _startColor = Colors.white;
  Color _endColor = Colors.orange;
  Duration _animationDuration = Duration(seconds: 5);
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  List<QueryDocumentSnapshot>? cartItems;

  // Declare a variable to hold the selected delivery option
  String selectedDeliveryOption = 'TakeAway'; // Set your default value here

  @override
  void initState() {
    super.initState();
    _animateBackground();
    fetchCartItems();
  }

  void _animateBackground() async {
    while (mounted) {
      setState(() {
        final temp = _startColor;
        _endColor = _startColor;
        _startColor = temp;
      });

      await Future.delayed(_animationDuration);
    }
  }

  Future<void> fetchCartItems() async {
    final cartItemsSnapshot =
        await FirebaseFirestore.instance.collection('cartItems').get();

    setState(() {
      cartItems = cartItemsSnapshot.docs;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Café Miron ',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: AnimatedContainer(
        duration: _animationDuration,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_startColor, _endColor],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: CartItemList()),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          child: GNav(
            gap: 8,
            tabBackgroundColor: Colors.orange,
            padding: const EdgeInsets.all(15),
            tabs: [
              GButton(
                icon: Icons.home,
                iconColor: Colors.orange,
                iconActiveColor: Colors.white,
                text: "Home",
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Homepage(),
                    ),
                  );
                },
              ),
              GButton(
                icon: Icons.favorite_border_outlined,
                iconColor: Colors.orange,
                textColor: Colors.white,
                text: "Favourites",
                iconActiveColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavPage(),
                    ),
                  );
                },
              ),
              GButton(
                icon: Icons.shopping_cart,
                iconColor: Colors.orange,
                text: "Cart",
                textColor: Colors.white,
                iconActiveColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showDeliveryOptionDialog();
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
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

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

        // Generate a new order ID
        String? orderId = _databaseRef.child("Orders").push().key;

        // Include order ID and selected delivery option in cart item data
        Map<String, dynamic> orderData = {
          "orderid": orderId,
          "title": title,
          "price": price,
          "imageUrl": imageUrl,
          "quantity": quantity,
          "deliveryOption": selectedDeliveryOption,
          "orderStatus": "Pending"
        };

        try {
          // Upload the cart item with order ID to the Realtime Database under "Orders"
          await _databaseRef.child("Orders").child(orderId!).set(orderData);

          // Upload the order data to Firestore in the 'History' collection
          await FirebaseFirestore.instance
              .collection('History')
              .doc(orderId)
              .set(orderData);

          // Delete the cart item from Firestore
          await FirebaseFirestore.instance
              .collection('cartItems')
              .doc(item.id)
              .delete();
          print("Order Placed");
        } catch (error) {
          print("Error placing order: $error");
        }
      }
    }
  }

  Future<void> _showDeliveryOptionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Delivery Option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  placeOrder();
                  setState(() {
                    selectedDeliveryOption = 'TakeAway';
                  });
                  Navigator.of(context).pop();
                  // Show a success alert here
                  showOrderPlacedAlert();
                },
                child: Text("Takeaway"),
              ),
              ElevatedButton(
                onPressed: () {
                  placeOrder();
                  setState(() {
                    selectedDeliveryOption = 'Cash on Delivery';
                  });
                  Navigator.of(context).pop();
                  // Show a success alert here
                  showOrderPlacedAlert();
                },
                child: Text("Cash on Delivery"),
              ),
            ],
          ),
        );
      },
    );
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

  Future<void> addToCart(
      String title, String price, String imageUrl, int quantity) async {
    String? cartItemId = _databaseRef.child("cartItems").push().key;

    Map<String, dynamic> cartItemData = {
      "title": title,
      "price": price,
      "imageUrl": imageUrl,
      "quantity": quantity,
    };

    await _databaseRef
        .child("cartItems")
        .child(cartItemId!)
        .set(cartItemData)
        .then((value) => print("Added to Cart"));
  }
}

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
        contentPadding: EdgeInsets.all(16.0),
        leading: Image.network(imageUrl, width: 80.0),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price: \$${priceDouble.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            Text(
              'Quantity: $quantity',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            FirebaseFirestore.instance
                .collection('cartItems')
                .doc(cartItem.id)
                .delete()
                .then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item removed from cart.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error removing item from cart: $error'),
                  duration: Duration(seconds: 2),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
