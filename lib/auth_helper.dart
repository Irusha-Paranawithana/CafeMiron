import 'package:miron/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton pattern to ensure a single instance of AuthHelper
  static AuthHelper? _instance;
  static AuthHelper get instance {
    _instance ??= AuthHelper();
    return _instance!;
  }

// Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = authResult.user;
      return user;
    } catch (e) {
      print("Error signing in with email and password: $e");
      return null;
    }
  }

//logout Method
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Set the 'isLoggedIn' flag to false when the user logs out
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}

Future<bool> isUserLoggedIn() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  return isLoggedIn;
}
