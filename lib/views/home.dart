import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:miron/auth_helper.dart';
import 'package:miron/cart.dart';
import 'package:miron/contact.dart';
import 'package:miron/faq.dart';
import 'package:miron/favourites.dart';
import 'package:miron/food_items/Burgers.dart';
import 'package:miron/model/confirmationDialog.dart';
import 'package:miron/myOrders.dart';
import 'package:miron/pages/Review.dart';
import 'package:miron/pages/firebase_service.dart';
import 'package:miron/screens/userDrawerHeader.dart';
import 'package:miron/screens/user_profile.dart';
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Café Miron',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserDrawerHeader(
                user: user,
                userName: userName,
                mobileNumber: mobileNumber,
              ),
              ListTile(
                leading: const Icon(Icons.person_3_rounded),
                title: const Text('Edit Profile'),
                onTap: () {
                  // Add your navigation logic for My Orders here
                  // For example, Navigator.pushNamed(context, '/my_orders');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                                userId: user!.uid,
                              )));
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('My Orders'),
                onTap: () {
                  // Add your navigation logic for My Orders here
                  // For example, Navigator.pushNamed(context, '/my_orders');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyOrders()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_document),
                title: const Text('Inquiries'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Review()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.question_answer),
                title: const Text('FAQ'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FAQPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail),
                title: const Text('Contact Us'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ContactUsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.power_settings_new),
                title: const Text('Logout'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmationDialog(
                        title: 'Logout Confirmation',
                        content: 'Are you sure you want to logout?',
                        confirmText: 'Yes, Logout',
                        cancelText: 'Cancel',
                        onConfirm: () {
                          // Perform the logout action here
                          AuthHelper.instance.logout(context);
                        },
                        onCancel: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
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
          child: SafeArea(
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
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            child: GNav(
              gap: 8,
              tabBackgroundColor: const Color.fromARGB(255, 251, 139, 64),
              padding: const EdgeInsets.all(20),
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
                    Navigator.of(context).push(_createRoute(CartPage()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom page transition animation
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
