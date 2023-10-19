import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Color _startColor = Colors.white;
  Color _endColor = Colors.orange;
  Duration _animationDuration = const Duration(seconds: 5);
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  List<QueryDocumentSnapshot>? cartItems;
  late String selectedDeliveryOption;

  Position? _currentUserPosition;
  double? distanceInMeter = 0.0;
  String? _userAddress;
  String? _residentialAddress;
  double? _residentialLatitude;
  double? _residentialLongitude;

  @override
  void initState() {
    super.initState();
    _getTheDistance();
    fetchCartItems();
    _convertAddressToCoordinates(_residentialAddress!);
    _convertToAddress(_userAddress as Position);
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

  //convert address to coordinates
  Future<void> _convertAddressToCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          _residentialLatitude = location.latitude;
          _residentialLongitude = location.longitude;
        });
      }
    } catch (e) {
      print("Error converting address to coordinates: $e");
    }
  }

  //fetch cart items

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
      body: AnimatedContainer(
        duration: _animationDuration,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_startColor, _endColor],
          ),
        ),
        child: const Column(
          children: [
            Expanded(child: CartItemList()),
          ],
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
            'Final Cart Price: \Rs${calculateFinalCartPrice().toStringAsFixed(2)}',
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
  Future<void> _getTheDistance() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      if (await Geolocator.checkPermission() == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      _currentUserPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print(_currentUserPosition!.latitude);
    }
    double mironlat = 6.329167109863599;
    double mironlng = 80.85799613887737;

    distanceInMeter = await Geolocator.distanceBetween(
        _currentUserPosition!.latitude,
        _currentUserPosition!.longitude,
        mironlat,
        mironlng);
    _convertToAddress(_currentUserPosition!);
  }

  //convert LatLng to address

  Future<void> _convertToAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String userAddress = placemark.thoroughfare ?? '';
        userAddress += ', ' + (placemark.subThoroughfare ?? '');
        userAddress += ', ' + (placemark.locality ?? '');
        userAddress += ', ' + (placemark.administrativeArea ?? '');
        userAddress += ', ' + (placemark.country ?? '');

        setState(() {
          _userAddress = userAddress;
        });
      }
    } catch (e) {
      print("Error reverse geocoding: $e");
    }
  }

  //place order

  Future<void> placeOrder(String selectedDeliveryOption) async {
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

          // Include user ID in cart item data
          Map<String, dynamic> orderData = {
            "userid": userId, // Include the user's ID
            "orderid": orderId,
            "title": title,
            "price": price,
            "imageUrl": imageUrl,
            "quantity": quantity,
            "orderStatus": "Pending"
          };

          try {
            // Upload the order data to Realtime Database under "Orders"
            await _databaseRef.child("Orders").child(orderId!).set(orderData);

            // Delete the cart item from Firestore
            await FirebaseFirestore.instance
                .collection('cartItems')
                .doc(item.id)
                .delete();

            print("Order Placed");
          } catch (error) {
            print("Error placing order: $error");
          }
        } else {
          // Handle the case when the user is not authenticated
          print("User is not authenticated.");
        }
      }
    }
  }

  //add to cart

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
                  setState(() {
                    selectedDeliveryOption = 'TakeAway';
                  });
                  Navigator.of(context).pop();
                  placeOrder(selectedDeliveryOption);
                  // Show a success alert here
                  showOrderPlacedAlert();
                },
                child: Text("Takeaway"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedDeliveryOption = 'Cash on Delivery';
                  });
                  if (distanceInMeter == null || distanceInMeter! > 3000) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Cash on Delivery is unavailable to your location.'),
                      ),
                    );
                  } else {
                    Navigator.of(context).pop();
                    placeOrder(selectedDeliveryOption);
                  }
                },
                child: Text("Cash on Delivery"),
              ),
            ],
          ),
        );
      },
    );
  }

  // alert dialog

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
