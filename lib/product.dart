import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:miron/cart.dart';
import 'package:miron/favourites.dart';
import 'package:miron/pages/Review.dart';
import 'package:miron/views/home.dart';

class Product extends StatefulWidget {
  final Map<String, dynamic> burgerData;

  Product({required this.burgerData, Key? key}) : super(key: key);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  Color _startColor = Colors.white;
  Color _endColor = Colors.orange;

  // Animation duration
  Duration _animationDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    // Start the animation
    _animateBackground();
  }

  void _animateBackground() async {
    while (mounted) {
      // Swap start and end colors
      setState(() {
        final temp = _startColor;
        _startColor = _endColor;
        _endColor = temp;
      });

      // Wait for the specified duration
      await Future.delayed(_animationDuration);
    }
  }

  int quantity = 1;

  Future<void> addToCart(int quantity) async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection("cartItems");

    // Generate a new document ID for the cart item
    String itemId = _collectionRef.doc().id;

    // Add data to the "cartItems" collection with the generated document ID
    return _collectionRef.doc(itemId).set({
      "title": widget.burgerData['title'],
      "price": widget.burgerData['price'],
      "imageUrl": widget.burgerData['imageUrl'],
      "quantity": quantity, // Include quantity in the data
    }).then((value) => print("Added to Cart"));
  }

  Future<void> addToFav() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection("Favourites");

    // Generate a new document ID for the cart item
    String favId = _collectionRef.doc().id;

    // Add data to the "cartItems" collection with the generated document ID
    return _collectionRef.doc(favId).set({
      "title": widget.burgerData['title'],
      "price": widget.burgerData['price'],
      "imageUrl": widget.burgerData['imageUrl'],
    }).then((value) => print("Added to Favourites"));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.burgerData['title'];
    final price = widget.burgerData['price'];
    final description = widget.burgerData['description'];
    final imageUrl = widget.burgerData['imageUrl'];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Café Miron'), // Set app bar title
          backgroundColor: Colors.orange, // Set app bar background color
        ),
        body: AnimatedContainer(
          // Wrap the content with AnimatedContainer
          duration: _animationDuration,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_startColor, _endColor], // Use the animated colors
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Image.network(imageUrl),
                  ),
                  buttonArrow(context),
                ],
              ),
              Expanded(
                child: scroll(title, price, description),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            child: GNav(
              gap: 8,
              tabBackgroundColor: Color.fromARGB(255, 251, 139, 64),
              padding: EdgeInsets.all(20),
              tabs: [
                GButton(
                  icon: Icons.home,
                  iconColor: Color.fromARGB(255, 251, 139, 64),
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
                  iconColor: Color.fromARGB(255, 251, 139, 64),
                  text: "Favourites",
                  textColor: Colors.white,
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
                  iconColor: Color.fromARGB(255, 251, 139, 64),
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
                GButton(
                  icon: Icons.edit_document,
                  iconColor: Color.fromARGB(255, 251, 139, 64),
                  text: "Inquiries",
                  textColor: Colors.white,
                  iconActiveColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Review(),
                      ),
                    );
                  },
                ),
                GButton(
                  icon: Icons.person,
                  iconColor: Color.fromARGB(255, 251, 139, 64),
                  text: "User",
                  textColor: Colors.white,
                  iconActiveColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonArrow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Return to the previous screen
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Colors.orange,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget scroll(String title, String price, String description) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 1.0,
      minChildSize: 0.6,
      builder: (context, ScrollController) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: ScrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 5,
                        width: 35,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 50,
                ),
                Row(
                  children: [
                    Text(
                      'Rs ' + price,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 60,
                ),
                Text(
                  "Description",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 150,
                  padding: EdgeInsets.all(3.0), // Add padding to the container
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        5.0), // Add rounded corners to the rectangle
                    color: Colors.orange, // Set the background color
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.remove,
                          color: Colors.white, // Set the color to orange
                        ),
                      ),
                      Text(
                        quantity.toString(),
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: Icon(
                          Icons.add,
                          color: Colors.white, // Set the color to orange
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => addToCart(quantity),
                      icon: Icon(Icons.shopping_cart),
                      label: Text("Add To Cart"),
                      style: ElevatedButton.styleFrom(
                        primary:
                            Colors.green, // Set the background color to green
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => addToFav(),
                      icon: Icon(Icons.favorite),
                      label: Text("Add To Favourites"),
                      style: ElevatedButton.styleFrom(
                        primary:
                            Colors.red, // Set the background color to green
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
