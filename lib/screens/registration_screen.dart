import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miron/model/user_model.dart';

import 'package:miron/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:miron/views/home.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // form key
  final _formKey = GlobalKey<FormState>();

  //firebase
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false; // Track loading state

  //editting controllers
  final userNameController = TextEditingController();
  final emailAddressController = TextEditingController();
  final residentialAddressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false; // Track password visibility
  bool _isConfirmPasswordVisible = false; // Track confirm password visibility

  @override
  Widget build(BuildContext context) {
    //userName field
    final userNameField = TextFormField(
      autofocus: false,
      controller: userNameController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$'); //entering minimum value 3
        if (value!.isEmpty) {
          return ("User Name Is Required");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid User Name (Min. 3 Characters)");
        }
        return null;
      },
      onSaved: (value) {
        userNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.account_circle),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: "User Name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Email field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailAddressController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        //reg exression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter valid Email");
        }
        return null;
      },
      onSaved: (value) {
        emailAddressController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: "Email Address",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //residentialAddress field
    final residentialAddressField = TextFormField(
      autofocus: false,
      controller: residentialAddressController,
      keyboardType: TextInputType.streetAddress,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$'); //entering minimum value 3
        if (value!.isEmpty) {
          return ("Residential Address Is Required");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid Address (Min. 3 Characters)");
        }
        return null;
      },
      onSaved: (value) {
        residentialAddressController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.pin_drop),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: "Residential Address",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //phoneNo field
    final phoneNumberField = TextFormField(
      autofocus: false,
      controller: phoneNumberController,
      keyboardType: TextInputType.phone,
      validator: (value) {
        // Use the updated regex pattern for exactly 10 digits
        if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
          return ("Enter a Valid 10-Digit Mobile Number");
        }
        if (value!.isEmpty) {
          return ("Mobile Number Is Required");
        }

        return null;
      },
      onSaved: (value) {
        phoneNumberController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.phone),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: "Mobile Number",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Password field
    final passwordField = Stack(
      children: [
        TextFormField(
          autofocus: false,
          controller: passwordController,
          obscureText: !_isPasswordVisible, // Toggle password visibility
          validator: (value) {
            RegExp regex = RegExp(r'^.{6,}$'); //entering minimum value 6
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
          textInputAction: TextInputAction.next,
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
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey, // Set the eye icon's color to gray
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

    //ConfirmPAssword field
    final confirmPasswordField = Stack(
      children: [
        TextFormField(
          autofocus: false,
          controller: confirmPasswordController,
          obscureText:
              !_isConfirmPasswordVisible, // Toggle confirm password visibility
          validator: (value) {
            if (confirmPasswordController.text != passwordController.text) {
              return "Password Don't Match";
            }
            return null;
          },
          onSaved: (value) {
            confirmPasswordController.text = value!;
          },
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            labelText: "Confirm Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: IconButton(
        //     icon: Icon(
        //       _isConfirmPasswordVisible
        //           ? Icons.visibility
        //           : Icons.visibility_off,
        //       color: Colors.grey, // Set the eye icon's color to gray
        //     ),
        //     onPressed: () {
        //       setState(() {
        //         _isConfirmPasswordVisible =
        //             !_isConfirmPasswordVisible; // Toggle visibility
        //       });
        //     },
        //   ),
        // ),
      ],
    );

    ///signup button
    final signUpButton = Material(
      elevation: 5,
      color: Colors.orange,
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width / 2,
        onPressed: () {
          signUp(emailAddressController.text, passwordController.text);
        },
        child: const Text(
          "SignUp",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
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
                        SizedBox(
                          height: 150,
                          child: Image.asset(
                            "assets/images/cafe_logo.png",
                            width: 130,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        userNameField,
                        const SizedBox(
                          height: 20,
                        ),
                        emailField,
                        const SizedBox(
                          height: 20,
                        ),
                        residentialAddressField,
                        const SizedBox(
                          height: 20,
                        ),
                        phoneNumberField,
                        const SizedBox(
                          height: 20,
                        ),
                        passwordField,
                        const SizedBox(
                          height: 20,
                        ),
                        confirmPasswordField,
                        const SizedBox(
                          height: 40,
                        ),
                        signUpButton,
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text("Already have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.orange),
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
          ),
          if (_isLoading) // Display loading indicator with a semi-transparent background
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

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await postDetailToFirestore();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
          (route) => false,
        );
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      } finally {
        if (mounted) {
          // Check if the widget is still mounted before calling setState
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
        }
      }
    }
  }

  postDetailToFirestore() async {
    //calling firebase
    //calling user model
    // sending these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    //writting all the values
    userModel.emailAddress = user!.email;
    userModel.uid = user.uid;
    userModel.userName = userNameController.text;
    userModel.residentialAddress = residentialAddressController.text;
    userModel.phoneNumber = phoneNumberController.text;
    userModel.password = passwordController.text;

    //creating new collection in firestore
    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Account Created Successfully !");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(
          builder: (context) => Homepage(),
        ),
        (route) => false);
  }
}
