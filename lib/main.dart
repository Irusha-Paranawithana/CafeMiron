import 'package:miron/map_utils.dart';
import 'package:miron/model/colors.dart';
import 'package:miron/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:miron/screens/startScreen.dart';
import 'package:miron/test.dart';
import 'package:miron/views/home.dart';
import 'package:miron/views/homeTemplate.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize uni_links

  //..........when the user once logged in, he directly moves to home
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  //........
  final bool isLoggedIn;
  const MyApp({required this.isLoggedIn});
  //'''''''
  //const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Email and password login',
        theme: ThemeData(
          primarySwatch:
              createMaterialColor(const Color.fromARGB(255, 3, 175, 255)),
        ),
        home: isLoggedIn ? HomePageTemplate() : StartScreen());
  }
}
