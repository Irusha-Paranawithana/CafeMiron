import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:miron/cart.dart';

import 'package:miron/favourites.dart';
import 'package:miron/food_items/Burgers.dart';

import 'package:miron/model/drawer.dart';

import 'package:miron/pages/Review.dart';
import 'package:miron/pages/firebase_service.dart';

import 'package:miron/views/widgets/receipe_card.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Café Miron',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Homepage(),
        '/favourites': (context) => FavPage(),
        '/cart': (context) => CartPage(),
        '/inquiries': (context) => const Review(),
      },
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Define initial gradient colors
  Color _startColor = Colors.white;
  Color _endColor = Colors.orange;

  // Animation duration
  final Duration _animationDuration = const Duration(seconds: 5);

  // Data variables
  List<Map<String, dynamic>> _foodTypes = [];
  QuerySnapshot? _dealsSnapshot;

  String? userName; // User name
  String? mobileNumber; // Mobile number
  String? photoURL; // User profile photo URL

  @override
  void initState() {
    super.initState();
    // Start the animation
    _animateBackground();
    // Fetch data
    _loadData();
    _loadUserData(); // Load user data
  }

  //load user data
  void _loadUserData() async {
    // Fetch additional user data from Firestore
    try {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        setState(() {
          userName = data['userName'];
          mobileNumber = data['phoneNumber'];
          photoURL = user?.photoURL;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Helper method to animate the background gradient
  void _animateBackground() async {
    while (true) {
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

  // Helper method to load data from Firebase
  Future<void> _loadData() async {
    final dealsSnapshot = await _firestore.collection('deals').get();
    final foodTypesSnapshot = await _firebaseService.getRecipes();

    setState(() {
      _dealsSnapshot = dealsSnapshot;
      _foodTypes = foodTypesSnapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white, // Set the background color to white
        drawer: AppDrawer(
          user: user,
          userName: userName, // Pass userName
          mobileNumber: mobileNumber, // Pass mobileNumber
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Center(
                    child: Text(
                      'HOT DEALS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _dealsSnapshot == null
                      ? const CircularProgressIndicator()
                      : CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                          ),
                          items: _dealsSnapshot!.docs.map((deal) {
                            final imageUrl = deal['imageUrl'] ?? '';
                            return Image.network(
                              imageUrl,
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      'WHAT\'S ON YOUR MIND',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _foodTypes.isEmpty
                      ? const CircularProgressIndicator()
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                          ),
                          itemCount: _foodTypes.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final recipeData = _foodTypes[index];
                            final title = recipeData['title'] ?? 'No Title';
                            final thumbnailUrl =
                                recipeData['thumbnailUrl'] ?? 'No Thumbnail';
                            return GestureDetector(
                              onTap: () {
                                // Navigate to the corresponding Dart file based on the title
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      if (title == 'Burgers') {
                                        return BurgerListView();
                                      } else {
                                        // Handle other food items here
                                        // You can create additional if conditions or use a switch statement
                                        // to navigate to different pages for each food item.
                                        // Return a default page or show an error message.
                                        return Container(
                                          child: const Text('Page not found'),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                              child: RecipeCard(
                                title: title,
                                thumbnailUrl: thumbnailUrl,
                                recipeData: recipeData,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // // Custom page transition animation
  // Route _createRoute(Widget page) {
  //   return PageRouteBuilder(
  //     pageBuilder: (context, animation, secondaryAnimation) => page,
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       const begin = Offset(1.0, 0.0);
  //       const end = Offset.zero;
  //       const curve = Curves.easeInOut;
  //       var tween =
  //           Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //       var offsetAnimation = animation.drive(tween);

  //       return SlideTransition(
  //         position: offsetAnimation,
  //         child: child,
  //       );
  //     },
  //   );
  // }
}
