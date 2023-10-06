import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miron/cart.dart';
import 'package:miron/favourites.dart';
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
        title: const Text('Café Miron'),
        backgroundColor: Colors.orange,
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
                      const Text(
                        'File an Inquiry',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Map<String, dynamic> data = {
                              "First Name": firstName.text,
                              "Last Name": lastName.text,
                              "Telephone Number": telephone.text,
                              "Email Address": emailAddress.text,
                              "Inquiry": inquiry.text,
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
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Submit'),
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
                onPressed: () {},
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
                        userId: user!.uid,
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

  Widget buildTextField(
    TextEditingController controller,
    String labelText,
    String? Function(String?)? validator, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: Colors.orange,
      ),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black, fontSize: 20),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 251, 139, 64),
            width: 2.0,
          ),
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
