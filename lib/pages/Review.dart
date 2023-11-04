import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miron/cart.dart';
import 'package:miron/favourites.dart';
import 'package:miron/model/colors.dart';
import 'package:miron/screens/user_profile.dart';

import 'package:miron/views/home.dart';

class Review extends StatefulWidget {
  const Review({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> with TickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController telephone = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController inquiry = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'File an Inquiry',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      buildTextField(firstName, 'First Name', (value) {
                        if (value!.isEmpty) {
                          return 'Enter First Name';
                        }
                        return null;
                      }),
                      const SizedBox(height: 20),
                      buildTextField(lastName, 'Last Name', (value) {
                        if (value!.isEmpty) {
                          return 'Enter Last Name';
                        }
                        return null;
                      }),
                      const SizedBox(height: 20),
                      buildTextField(telephone, 'Telephone Number', (value) {
                        if (value!.isEmpty) {
                          return 'Enter Telephone Number';
                        }
                        if (value.length != 10) {
                          return 'Please enter a valid phone number';
                        }
                        if (!isNumeric(value)) {
                          return 'Please enter only numbers';
                        }
                        return null;
                      }),
                      const SizedBox(height: 20),
                      buildTextField(emailAddress, 'Email Address', (value) {
                        if (value!.isEmpty) {
                          return 'Enter Email Address';
                        }
                        if (!value.contains('@')) {
                          return 'Email Address must contain "@" sign';
                        }
                        return null;
                      }),
                      const SizedBox(height: 20),
                      buildTextField(inquiry, 'Enter Message', (value) {
                        if (value!.isEmpty) {
                          return 'Enter Message';
                        }
                        return null;
                      }, maxLines: 6),
                      const SizedBox(height: 40),
                      FractionallySizedBox(
                        widthFactor: 0.6,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Map<String, dynamic> data = {
                                "First Name": firstName.text,
                                "Last Name": lastName.text,
                                "Telephone Number": telephone.text,
                                "Email Address": emailAddress.text,
                                "Inquiry": inquiry.text,
                                "Timestamp": FieldValue.serverTimestamp(),
                              };
                              FirebaseFirestore.instance
                                  .collection("Inquiry")
                                  .add(data);
                              firstName.clear();
                              lastName.clear();
                              telephone.clear();
                              emailAddress.clear();
                              inquiry.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: mainColor,
                            elevation: 5,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Submit',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Rest of your widget content
        ],
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String labelText,
    String? Function(String?)? validator, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: mainColor,
      ),
      maxLines: maxLines,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: mainColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }

  bool isNumeric(String? value) {
    if (value == null) {
      return false;
    }
    return double.tryParse(value) != null;
  }
}
