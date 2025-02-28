import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miron/model/colors.dart';
import 'package:miron/views/home.dart';

import '../model/user_profile.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  UserProfileScreen({required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController userNameController = TextEditingController();
  TextEditingController residentialAddressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    // Load user profile data when the screen is initialized
    loadUserProfile();
  }

  void loadUserProfile() async {
    try {
      // Fetch the user's profile data from Firestore using the provided userId
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        // Create a UserProfile object from the Firestore data
        UserProfile userProfile =
            UserProfile.fromMap(userSnapshot.data() as Map<String, dynamic>);

        // Set the text controllers to display the user's current data
        userNameController.text = userProfile.userName ?? '';
        residentialAddressController.text =
            userProfile.residentialAddress ?? '';
        phoneNumberController.text = userProfile.phoneNumber ?? '';
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  void updateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Show loading indicator
      });

      try {
        // Fetch the current user profile data from Firestore
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

        if (userSnapshot.exists) {
          // Create a UserProfile object from the Firestore data
          UserProfile currentUserProfile =
              UserProfile.fromMap(userSnapshot.data() as Map<String, dynamic>);

          // Create a new UserProfile object with the updated data
          UserProfile newProfile = UserProfile(
            userName: userNameController.text,
            residentialAddress: residentialAddressController.text,
            phoneNumber: phoneNumberController.text,
          );

          // Check if there are any changes
          if (currentUserProfile.userName != newProfile.userName ||
              currentUserProfile.residentialAddress !=
                  newProfile.residentialAddress ||
              currentUserProfile.phoneNumber != newProfile.phoneNumber) {
            // Update the user's profile data in Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .update(
              {
                'userName': userNameController.text,
                'residentialAddress': residentialAddressController.text,
                'phoneNumber': phoneNumberController.text,
              },
            );

            // Show a success message if changes were made
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: mainColor,
              ),
            );
          } else {
            // Show a Snackbar indicating no changes were made
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No changes were made to the profile.'),
                backgroundColor: mainColor,
              ),
            );
          }
        }
      } catch (e) {
        print('Error updating user profile: $e');
      } finally {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'User Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        height: 150,
                        child: Image.asset(
                          "assets/images/profile.png",
                          width: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      autofocus: false,
                      controller: userNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'User Name',
                        prefixIcon: Icon(Icons.account_circle),
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        RegExp regex = RegExp(r'^.{3,}$');
                        if (value!.isEmpty) {
                          return 'User Name is required';
                        }
                        if (!regex.hasMatch(value)) {
                          return 'Enter a valid User Name (Min. 3 Characters)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      autofocus: false,
                      controller: residentialAddressController,
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.pin_drop),
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        labelText: 'Residential Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        RegExp regex = RegExp(r'^.{3,}$');
                        if (value!.isEmpty) {
                          return 'Residential Address is required';
                        }
                        if (!regex.hasMatch(value)) {
                          return 'Enter a valid Address (Min. 3 Characters)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      autofocus: false,
                      keyboardType: TextInputType.phone,
                      controller: phoneNumberController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
                          return 'Enter a valid 10-Digit Mobile Number';
                        }
                        if (value.isEmpty) {
                          return 'Mobile Number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 50),
                    Center(
                      child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : updateUserProfile,
                          child: Text('Update Profile'),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: isLoading,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
