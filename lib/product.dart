import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miron/model/colors.dart';

class Product extends StatefulWidget {
  final Map<String, dynamic> burgerData;

  Product(
      {required this.burgerData,
      Key? key,
      required Map PastryData,
      required Map IceCreamData,
      required Map coffeeData,
      required Map CoffeeData,
      required Map ChickenData,
      required Map JuiceData,
      required Map SaladData})
      : super(key: key);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  int quantity = 1;
  bool isFavorite = false; // Initialize as not a favorite

  @override
  void initState() {
    super.initState();
    checkFavorite(); // Check if the item is in favorites when the widget is created
  }

  Future<void> checkFavorite() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection("Favourites");

    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, include the UID in the favorite item data
      String userUID = user.uid;

      // Check if the item is already in favorites for the current user
      QuerySnapshot querySnapshot = await _collectionRef
          .where("title", isEqualTo: widget.burgerData['title'])
          .where("userUID", isEqualTo: userUID)
          .limit(1)
          .get();

      setState(() {
        isFavorite = querySnapshot.docs.isNotEmpty;
      });
    }
  }

  Future<void> addToCart(int quantity) async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection("cartItems");

    // Generate a new document ID for the cart item
    String itemId = _collectionRef.doc().id;

    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, include the UID in the cart item data
      String userUID = user.uid;

      // Add data to the "cartItems" collection with the generated document ID
      return _collectionRef.doc(itemId).set({
        "title": widget.burgerData['title'],
        "price": widget.burgerData['price'],
        "imageUrl": widget.burgerData['imageUrl'],
        "quantity": quantity,
        "userUID": userUID, // Include the user's UID in the data
      }).then((value) {
        print('Added to Cart');
        // Show a SnackBar to confirm the item has been added to the cart
        const snackBar = SnackBar(
          content: Text('Added to Cart'),
          duration: Duration(seconds: 2),
          backgroundColor: mainColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      print('User is not signed in');
    }
  }

  Future<void> toggleFavorite() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection("Favourites");

    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, include the UID in the favorite item data
      String userUID = user.uid;

      // Check if the item is already in favorites
      QuerySnapshot querySnapshot = await _collectionRef
          .where("title", isEqualTo: widget.burgerData['title'])
          .where("userUID", isEqualTo: userUID) // Check for the user's UID
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Item is already in favorites, remove it
        querySnapshot.docs.first.reference.delete();
      } else {
        // Item is not in favorites, add it
        String favId = _collectionRef.doc().id;
        await _collectionRef.doc(favId).set({
          "title": widget.burgerData['title'],
          "price": widget.burgerData['price'],
          "imageUrl": widget.burgerData['imageUrl'],
          "userUID": userUID, // Include the user's UID in the data
        });
      }

      setState(() {
        isFavorite = !isFavorite; // Toggle the favorite state
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isFavorite ? 'Added to Favorites' : 'Removed from Favorites'),
          duration: Duration(seconds: 2),
          backgroundColor: mainColor,
        ),
      );
    } else {
      // User is not signed in, handle this case as needed
      print('User is not signed in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.burgerData['title'] ?? "Default Title";
    final price = widget.burgerData['price'];
    final description =
        widget.burgerData['description'] ?? "Default Description";
    final imageUrl = widget.burgerData['imageUrl'] ?? "Default Image URL";

    // Validate and handle the price

    final formattedPrice = double.tryParse(price ?? "");
    final displayPrice = formattedPrice != null
        ? 'Rs. ${formattedPrice.toStringAsFixed(2)}'
        : 'Invalid Price';
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Café Miron',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: mainColor,
        ),
        body: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2.5,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Expanded(
              child: scroll(title, displayPrice, description),
            ),
          ],
        ),
      ),
    );
  }

  Widget scroll(String title, String price, String description) {
    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      maxChildSize: 1.0,
      minChildSize: 1.0,
      builder: (context, ScrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: const BorderRadius.only(
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
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: mainColor,
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => toggleFavorite(),
                        child: Icon(
                          Icons.favorite,
                          color: isFavorite ? mainColor : Colors.white,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  width: 50,
                ),
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Description",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: mainColor,
                      ),
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      constraints: BoxConstraints(maxWidth: 40),
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: mainColor,
                      ),
                      child: IconButton(
                        alignment: Alignment.center,
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: Container(
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Total = ',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      (((price.split(' .').length > 1
                                  ? (double.tryParse(price.split(' .')[1]) ??
                                      0.0)
                                  : 0.0) *
                              quantity)
                          .toString()),
                      style: const TextStyle(
                        fontSize: 17,
                        color: mainColor,
                      ),
                    ),
                    Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: ElevatedButton.icon(
                        onPressed: () => addToCart(quantity),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text(
                          "Add To Cart",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 49, 180, 53),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
