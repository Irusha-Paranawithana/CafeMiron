import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product extends StatefulWidget {
  final Map<String, dynamic> burgerData;
  Product({required this.burgerData, Key? key}) : super(key: key);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
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
    }).then((value) {
      print('Added to Cart'); // Print a message to the console
      // Show a SnackBar to confirm the item has been added to the cart
      final snackBar = const SnackBar(
        content: Text('Added to Cart'),
        duration: Duration(seconds: 2), // Adjust the duration as needed
        backgroundColor: Colors.orange,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  Future<void> addToFav() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection("Favourites");

    // Check if the item is already in favorites
    QuerySnapshot querySnapshot = await _collectionRef
        .where("title", isEqualTo: widget.burgerData['title'])
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Item is already in favorites, show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item is already in Favorites'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // Item is not in favorites, add it
      String favId = _collectionRef.doc().id;
      await _collectionRef.doc(favId).set({
        "title": widget.burgerData['title'],
        "price": widget.burgerData['price'],
        "imageUrl": widget.burgerData['imageUrl'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to Favorites'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.burgerData['title'];
    final price = widget.burgerData['price'];
    final description = widget.burgerData['description'];
    final imageUrl = widget.burgerData['imageUrl'];

    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Café Miron',
              style: TextStyle(color: Colors.white),
            ), // Set app bar title
            backgroundColor: Colors.orange, // Set app bar background color
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
                child: scroll(title, price, description),
              ),
            ],
          )),
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
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
                      'Rs. ' + price,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Description",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 40,
                      height: 40, // Set width and height to make it round
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, // Make it a circle
                        color: Colors.orange,
                      ),
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
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Container(
                      width: 25,
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Container(
                      width: 40,
                      height: 40, // Set width and height to make it round
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, // Make it a circle
                        color: Colors.orange,
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => addToCart(quantity),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text("Add To Cart"),
                      style: ElevatedButton.styleFrom(
                        primary:
                            Colors.green, // Set the background color to green
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => addToFav(),
                      icon: const Icon(Icons.favorite),
                      label: const Text("Add To Favourites"),
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
