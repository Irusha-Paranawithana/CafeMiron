import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:miron/cart.dart';
import 'package:miron/favourites.dart';
import 'package:miron/model/colors.dart';
import 'package:miron/model/drawer.dart';
import 'package:miron/pages/Review.dart';
import 'package:miron/pages/firebase_service.dart';
import 'package:miron/views/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Café Miron',
      theme: ThemeData(
        primarySwatch:
            createMaterialColor(const Color.fromARGB(255, 3, 175, 255)),
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

class HomePageTemplate extends StatefulWidget {
  const HomePageTemplate({Key? key}) : super(key: key);

  @override
  State<HomePageTemplate> createState() => _HomepageState();
}

class _HomepageState extends State<HomePageTemplate> {
  //bottom nav bar
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int index = 0;

  final screens = [
    Homepage(),
    FavPage(),
    CartPage(),
  ];

  final items = <Widget>[
    const Icon(
      Icons.home,
      size: 30,
    ),
    const Icon(
      Icons.favorite,
      size: 30,
    ),
    const Icon(
      Icons.shopping_cart,
      size: 30,
    ),
  ];

  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data variables
  List<Map<String, dynamic>> _foodTypes = [];
  QuerySnapshot? _dealsSnapshot;

  String? userName; // User name
  String? mobileNumber; // Mobile number
  String? photoURL; // User profile photo URL

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Café Miron',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
      ),
      drawer: AppDrawer(
        user: user,
        userName: userName, // Pass userName
        mobileNumber: mobileNumber, // Pass mobileNumber
      ),
      body: screens[index],

      //bottom navigation bar
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            iconTheme:
                const IconThemeData(color: Colors.white)), //change icon color
        child: CurvedNavigationBar(
          key: navigationKey,
          height: 60,
          backgroundColor: Colors.transparent,
          color: mainColor,
          buttonBackgroundColor: mainColor,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          items: items,
          index: index,
          onTap: (index) => setState(() => this.index = index),
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
