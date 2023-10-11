import 'package:miron/auth_helper.dart';
import 'package:miron/screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:miron/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Track password visibility

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signInWithEmailPassword() async {
    final AuthHelper authHelper = AuthHelper.instance;
    final String email = emailController.text;
    final String password = passwordController.text;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final User? user =
          await authHelper.signInWithEmailAndPassword(email, password);

      if (user != null) {
        Fluttertoast.showToast(msg: "Login Successful");

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        Fluttertoast.showToast(
            msg: "Login Failed. Please check your credentials.");
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter a valid Email");
        }
        return null;
      },
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final passwordField = Stack(
      children: [
        TextFormField(
          autofocus: false,
          controller: passwordController,
          obscureText: !_isPasswordVisible, // Toggle password visibility
          validator: (value) {
            RegExp regex = RegExp(r'^.{6,}$');
            if (value!.isEmpty) {
              return ("Password Is Required");
            }
            if (!regex.hasMatch(value)) {
              return ("Enter Valid Password (Min. 6 Characters)");
            }
            return null;
          },
          onSaved: (value) {
            passwordController.text = value!;
          },
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            labelText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off, // Toggle password visibility
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
              });
            },
          ),
        ),
      ],
    );

    final loginButton = Stack(
      children: [
        Material(
            elevation: 5,
            color: Colors.orange,
            borderRadius: BorderRadius.circular(30),
            child: IgnorePointer(
              ignoring: _isLoading,
              child: MaterialButton(
                padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                minWidth: MediaQuery.of(context).size.width * 0.5,
                onPressed: () {
                  signInWithEmailPassword();
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
            )),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 80,
                      ),
                      SizedBox(
                        height: 200,
                        child: Image.asset(
                          "assets/images/cafe_logo.png",
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                        height: 45,
                      ),
                      emailField,
                      const SizedBox(
                        height: 20,
                      ),
                      passwordField,
                      const SizedBox(
                        height: 40,
                      ),
                      loginButton,
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegistrationScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "SignUp",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.orange,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
