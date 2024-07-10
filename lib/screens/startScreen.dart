import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:miron/model/colors.dart';
import 'package:miron/screens/login_screen.dart';
import 'package:miron/screens/registration_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  Widget loginButton(BuildContext context) {
    return Stack(
      children: [
        Material(
          elevation: 5,
          color: mainColor,
          borderRadius: BorderRadius.circular(30),
          child: MaterialButton(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            minWidth: MediaQuery.of(context).size.width * 0.6,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text(
              "Login",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget signupButton(BuildContext context) {
    return Stack(
      children: [
        Material(
          elevation: 5,
          color: mainColor,
          borderRadius: BorderRadius.circular(30),
          child: MaterialButton(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            minWidth: MediaQuery.of(context).size.width * 0.6,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegistrationScreen()));
            },
            child: const Text(
              "Sign Up",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40.0),
            Lottie.asset('assets/animations/Hi Ani.json'),
            const SizedBox(height: 20.0),
            const Text(
              'Welcome to',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Gamunu Restaurant',
              style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              'Best foods',
              style: TextStyle(
                fontSize: 25.0,
                color: Color.fromARGB(255, 118, 118, 118),
              ),
            ),
            Spacer(),
            Column(
              children: [
                const SizedBox(height: 20.0),
                loginButton(context),
                const SizedBox(height: 20.0),
                signupButton(context),
                const SizedBox(height: 50.0),
              ],
            )
          ],
        ),
      ),
    );
  }
}
