import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:miron/favourites.dart';
import 'package:miron/model/colors.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.reference();
  List<QueryDocumentSnapshot>? cartItems;
  late String selectedDeliveryOption;

  Position? _currentUserPosition;
  double? distanceInMeter = 0.0;
  String? userAddress;
  String? _residentialAddress;
  double? _residentialLatitude;
  double? _residentialLongitude;

  @override
  void initState() {
    super.initState();
    _getTheDistance();
    fetchCartItems();
    _getTheDistanceResidence();
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

  String placeM = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: CartItemList(cartItems)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showDeliveryOptionDialog();
        },
        label: Text('Place the Order'),
        icon: Icon(Icons.shopping_bag),
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
  }

  Future<void> _getTheDistanceResidence() async {
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
        _residentialLatitude!, _residentialLongitude!, mironlat, mironlng);
  }

  Future<void> _retrieveAddress() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentUserPosition!.latitude, _currentUserPosition!.longitude);

    print(placemarks);

    Placemark place = placemarks[0];

    placeM =
        '${place.thoroughfare},${place.street},${place.subLocality},${place.locality},${place.subAdministrativeArea},${place.administrativeArea},${place.postalCode},${place.country}';

    setState(() {
      userAddress = placeM;
    });
  }

  Future<void> _getCoordinates() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final residentialAddress = userData['residentialAddress'] as String;

        if (residentialAddress != null) {
          List<Location> location =
              await locationFromAddress(residentialAddress);
          _residentialLatitude = double.parse('${location.last.latitude}');
          _residentialLongitude = double.parse('${location.last.longitude}');
        }
      }
    }
  }

  Future<void> placeOrder(String selectedDeliveryOption) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Fetch the cart items for the current user
        final cartItemsSnapshot = await FirebaseFirestore.instance
            .collection('cartItems')
            .where("userUID", isEqualTo: user.uid)
            .get();

        if (cartItemsSnapshot.docs.isNotEmpty) {
          final userId = user.uid;
          final orderId = _databaseRef.child("Orders").push().key;
          final timestamp = DateTime.now().toLocal().toString();

          Map<String, dynamic> orderData = {
            "userid": userId,
            "orderid": orderId,
            "orderStatus": "Pending",
            "Address": userAddress,
            "timestamp": timestamp,
            "selectedDeliveryOption": selectedDeliveryOption,
            "items": cartItemsSnapshot.docs.map((item) {
              final data = item.data() as Map<String, dynamic>;
              return {
                "title": data['title'],
                "price": data['price'],
                "imageUrl": data['imageUrl'],
                "quantity": data['quantity'],
              };
            }).toList(),
          };

          await _databaseRef.child("Orders").child(orderId!).set(orderData);

          // Delete individual cart items
          for (final item in cartItemsSnapshot.docs) {
            await FirebaseFirestore.instance
                .collection('cartItems')
                .doc(item.id)
                .delete();
          }

          print("Order Placed");
          showOrderPlacedAlert();
        } else {
          print("Cart is empty.");
        }
      } catch (error) {
        print("Error placing order: $error");
      }
    } else {
      print("User is not authenticated.");
    }
  }

  Future<void> addToCart(
      String title, String price, String imageUrl, int quantity) async {
    final User? user = _auth.currentUser;

    if (user != null) {
      String? cartItemId = _databaseRef.child("cartItems").push().key;

      Map<String, dynamic> cartItemData = {
        "title": title,
        "price": price,
        "imageUrl": imageUrl,
        "quantity": quantity,
        "userUID": user.uid,
      };

      await _databaseRef
          .child("cartItems")
          .child(cartItemId!)
          .set(cartItemData)
          .then((value) => print("Added to Cart"));
    }
    // Delete individual cart items
  }

  Future<void> fetchCartItems() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        final cartItemsSnapshot = await FirebaseFirestore.instance
            .collection('cartItems')
            .where("userUID", isEqualTo: user.uid)
            .get();

        setState(() {
          cartItems = cartItemsSnapshot.docs;
        });
      } catch (error) {
        print("Error fetching cart items: $error");
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
                  setState(() async {
                    final User? user = _auth.currentUser;
                    if (user != null) {
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get();
                      if (userDoc.exists) {
                        final userData = userDoc.data() as Map<String, dynamic>;
                        final residentialAddress =
                            userData['residentialAddress'] as String;

                        userAddress = residentialAddress;
                        selectedDeliveryOption = 'TakeAway';
                        placeOrder(selectedDeliveryOption);
                      }
                    }
                  });
                  Navigator.of(context).pop();
                  placeOrder(selectedDeliveryOption);
                },
                child: Text("Takeaway"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedDeliveryOption = 'Cash On Delivery';
                  });
                  Navigator.of(context).pop();
                  _showDeliverylocationDialog();
                },
                child: Text("Cash On Delivery"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeliverylocationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Delivery Location"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  await _getCoordinates();
                  await _getTheDistance();
                  await _retrieveAddress();

                  if (distanceInMeter != null && distanceInMeter! <= 3000) {
                    placeOrder(selectedDeliveryOption);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Delivery location is too far.'),
                        duration: Duration(seconds: 2),
                        backgroundColor: mainColor,
                      ),
                    );
                  }

                  Navigator.of(context).pop();
                },
                child: Text("Current Location"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final User? user = _auth.currentUser;
                  if (user != null) {
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();
                    if (userDoc.exists) {
                      final userData = userDoc.data() as Map<String, dynamic>;
                      final residentialAddress =
                          userData['residentialAddress'] as String;
                      await _getCoordinates();

                      await _getTheDistanceResidence();

                      if (distanceInMeter != null && distanceInMeter! <= 3000) {
                        placeOrder(selectedDeliveryOption);
                        userAddress = residentialAddress;
                        showOrderPlacedAlert();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Delivery location is too far.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  }

                  Navigator.of(context).pop();
                },
                child: Text("Your Address"),
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
}

class CartItemList extends StatelessWidget {
  final List<QueryDocumentSnapshot>? cartItems;

  CartItemList(this.cartItems, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return cartItems == null || cartItems!.isEmpty
        ? Center(
            child: Text(
              'Your cart is empty.',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          )
        : ListView.builder(
            itemCount: cartItems?.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems![index];
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
