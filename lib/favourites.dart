import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:miron/cart.dart';
import 'package:miron/model/user_profile.dart';
import 'package:miron/pages/Review.dart';
import 'package:miron/screens/user_profile.dart';

import 'package:miron/views/home.dart';

class FavPage extends StatefulWidget {
  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  User? user = FirebaseAuth.instance.currentUser;
  Color _startColor = Colors.white;
  Color _endColor = Colors.orange;
  Duration _animationDuration = Duration(seconds: 5);

// Initially select the "Favourites" tab

  @override
  void initState() {
    super.initState();
    _animateBackground();
  }

  void _animateBackground() async {
    while (mounted) {
      setState(() {
        final temp = _startColor;
        _startColor = _endColor;
        _endColor = temp;
      });
      await Future.delayed(_animationDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Café Miron ',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 0, // Remove app bar shadow
      ),
      body: CartItemList(), // Place CartItemList in the body
      bottomNavigationBar: Container(
        color: Colors.grey.shade900, // Set background color to white
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          child: GNav(
            gap: 8,
            tabBackgroundColor: Colors.orange,
            padding: EdgeInsets.all(20),
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
                text: "Favourites",
                textColor: Colors.white,
                iconActiveColor: Colors.white,
                onPressed: () {},
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
              GButton(
                icon: Icons.edit_document,
                iconColor: Colors.orange,
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
                iconColor: Colors.orange,
                text: "User",
                textColor: Colors.white,
                iconActiveColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                        userId: user!.uid, // Pass the current user's ID
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItemList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Favourites').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final cartItems = snapshot.data!.docs;

        if (cartItems.isEmpty) {
          return Center(
            child: Text(
              'You don\'t have any Favourites.',
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
              price: data['price'],
              imageUrl: data['imageUrl'],
              cartItem: cartItem,
              quantity: data['quantity'] as int?,
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
  final QueryDocumentSnapshot cartItem;
  final int? quantity;

  CartItemTile({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.cartItem,
    this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final double priceDouble = double.parse(price);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
              'Price: Rs $priceDouble',
              style: TextStyle(fontSize: 16.0),
            ),
            if (quantity != null)
              Text(
                'Quantity: $quantity',
                style: TextStyle(fontSize: 16.0),
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
                .collection('Favourites')
                .doc(cartItem.id)
                .delete()
                .then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item removed from Favourites.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error removing item from Favourites: $error'),
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
